#imports
# Importing the required libraries
import essentia.standard as es
import essentia.streaming as ess
import essentia
import numpy as np
from scipy.spatial.distance import cosine, euclidean
from pydub import AudioSegment, generators
import tkinter as tk
from tkinter import filedialog
import soundfile as sf
import matplotlib.pyplot as plt
import demucs.separate
import librosa
import os
import glob
import soundfile as sf
import shutil

class mlSample:
    def __init__(self, path, loop_path):
        self.path = path
        self.sr = 0
        self.title = ""
        self.artist_name = ""
        self.length = 0
        self.key = ""
        self.key_strength = 0
        self.scale = ""
        self.major_key = ""
        self.tempo = 0
        self.beats = []
        self.beat_confidence = []
        self.loop_points = []
        self.loop_path = loop_path
        self.deck_path = loop_path
        self.genre = ""

    def load_sample(self):
        audio = self.load_file()
        self.load_key()
        self.load_rhythm()
        self.load_loops()
        # self.load_genre()
        #self.chop()

    def load_file(self):
        if self.path:
            # Load the selected audio file
            loader = es.MonoLoader(filename=self.path)
            audio = loader()
            
            # Load the same audio file in stereo for playback/export
            _, self.sr, _, _, _, _ = es.AudioLoader(filename=self.path)()
            
            audio = audio / np.max(np.abs(audio)) # Normalize the audio

            # Load Length
            # Load Title
            # Load Artist Name

            self.title = os.path.splitext(os.path.basename(self.path))[0]

            # Process the audio as needed...
            print("Audio loaded and processed.")
        return audio  # Implement this

    def load_key(self):
        loader = ess.MonoLoader(filename=self.path)
        framecutter = ess.FrameCutter(frameSize=4096, hopSize=2048)
        windowing = ess.Windowing(type='blackmanharris62')
        spectrum = ess.Spectrum()
        spectralpeaks = ess.SpectralPeaks(orderBy='magnitude',
                                        magnitudeThreshold=0.00001,
                                        minFrequency=20,
                                        maxFrequency=3500,
                                        maxPeaks=60)

        hpcp = ess.HPCP()
        hpcp_key = ess.HPCP(size=36,
                            referenceFrequency=440,
                            bandPreset=False,
                            minFrequency=20,
                            maxFrequency=3500,
                            weightType='cosine',
                            nonLinear=False,
                            windowSize=1.)

        key = ess.Key(profileType='edma',
                    numHarmonics=4,
                    pcpSize=36,
                    slope=0.6,
                    usePolyphony=True,
                    useThreeChords=True)

        # Use pool to store data.
        pool = essentia.Pool()

        # Connect streaming algorithms.
        loader.audio >> framecutter.signal
        framecutter.frame >> windowing.frame >> spectrum.frame
        spectrum.spectrum >> spectralpeaks.spectrum
        spectralpeaks.magnitudes >> hpcp.magnitudes
        spectralpeaks.frequencies >> hpcp.frequencies
        spectralpeaks.magnitudes >> hpcp_key.magnitudes
        spectralpeaks.frequencies >> hpcp_key.frequencies
        hpcp_key.hpcp >> key.pcp
        hpcp.hpcp >> (pool, 'tonal.hpcp')
        key.key >> (pool, 'tonal.key_key')
        key.scale >> (pool, 'tonal.key_scale')
        key.strength >> (pool, 'tonal.key_strength')

        # Run streaming network.
        essentia.run(loader)

        self.key = pool['tonal.key_key']
        self.scale = pool['tonal.key_scale']
        self.key_strength = pool['tonal.key_strength']

        # print(self.key)

        if self.scale == 'minor':
            self.major_key = self.minor_to_relative_major(pool['tonal.key_key'])
        else:
            self.major_key = self.key

    def load_rhythm(self):
        print('loading rhythm')

        loader = es.MonoLoader(filename=self.path)
        audio = loader()

        # Normalize the audio
        audio = audio / np.max(np.abs(audio))
        # Initialize the algorithm
        rhythm_extractor = es.RhythmExtractor2013()

        # Compute BPM, beat positions, etc.
        bpm, beats, beats_confidence, _, _ = rhythm_extractor(audio)
        
        self.tempo = bpm
        self.beats = beats
        self.beat_confidence = beats_confidence
        
        # pass  # Implement this

    def load_loops(self):
        print('loading loops')

        loader = es.MonoLoader(filename=self.path)
        audio = loader()

        # Normalize the audio
        audio = audio / np.max(np.abs(audio))

        # Initialize the algorithm
        rhythm_extractor = es.RhythmExtractor2013()

        # Compute BPM, beat positions, etc.
        _, beats, _, _, _ = rhythm_extractor(audio)

        chunks = divide_into_chunks(audio, beats, self.sr)

        # Step 2: Extract features from each chunk
        for chunk in chunks:
            chunk.extract_features()

        top_scores = detect_loops_with_exponents_of_2(chunks, top_n=8)

        self.loop_points = [(int(chunks[i].start_time * self.sr), int(chunks[j].end_time * self.sr)) for i, j, _ in top_scores]

        export_loop_segments(audio, int(self.sr), chunks, top_scores, self.title[:4], self.loop_path)

    def load_genre(self):
        pass  # Implement this

    def chop(self, audio):
        pass  # Implement this

    def minor_to_relative_major(self, key):
        minor_to_major = {
            'A': 'C',
            'A#': 'Db',
            'Bb': 'Db',
            'B': 'D',
            'C': 'Eb',
            'C#': 'E',
            'Db': 'E',
            'D': 'F',
            'D#': 'Gb',
            'Eb': 'Gb',
            'E': 'G',
            'F': 'Ab',
            'F#': 'A',
            'Gb': 'A',
            'G': 'Bb',
            'G#': 'B',
            'Ab': 'B'
        }
        return minor_to_major.get(key, key)

class mlCrate:
    def __init__(self, path):
        self.path = path
        self.song_count = 0
        self.total_duration = 0
        self.csv = ""
        self.samples = []
        self.loops_path = os.path.join(self.path, 'loops/')
        self.decks_path = os.path.join(self.path, 'decks/')

    def load_samples(self):
        # Go through the crate folder path
        audio_files_extensions = ['*.wav', '*.mp3', '*.flac']
        for extension in audio_files_extensions:
            for audio_file in glob.glob(os.path.join(self.path, extension)):
                # For every audio file, create an mlSample instance in the samples list
                sample = mlSample(audio_file, self.loops_path)
                # Call load_sample on it
                sample.load_sample()
                self.samples.append(sample)
    
    def load_decks(self):
        # Create a subfolder in the decks path for each original song name
        for sample in self.samples:
            original_song_name = os.path.splitext(os.path.basename(sample.path))[0]
            deck_folder = os.path.join(self.decks_path, original_song_name)
            os.makedirs(deck_folder, exist_ok=True)
            
            # Iterate over the WAV files in the loop folder
            loop_files = glob.glob(os.path.join(sample.loop_path, '*.wav'))
            for i, loop_file in enumerate(loop_files):
                # Define the export path for the loop segment
                export_path = os.path.join(deck_folder, f"{original_song_name}_loop_{i+1}.wav")
                
                # Copy the loop segment to the deck folder
                shutil.copyfile(loop_file, export_path)
                
                print(f"Exported loop segment {i+1} for {original_song_name}")
    

class AudioChunk:
    def __init__(self, start_time, end_time, audio_data, sample_rate, analysis_length=None):
        self.start_time = start_time
        self.end_time = end_time
        self.audio_data = audio_data
        self.sample_rate = sample_rate
        self.analysis_length = analysis_length  # Maximum length for analysis
        self.chroma = None
        self.mfcc = None
        self.rms = None

    def extract_features(self):
        # Adjust audio data length for analysis based on analysis_length
        if self.analysis_length is not None:
            analysis_samples = int(self.analysis_length * self.sample_rate)
            analysis_data = self.audio_data[:analysis_samples]
        else:
            analysis_data = self.audio_data

        # Extract features from analysis_data instead of the full audio_data
        # print(1)
        # print(len(analysis_data))
        self.chroma = librosa.feature.chroma_stft(y=analysis_data, sr=self.sample_rate)
        # print(2)
        self.mfcc = librosa.feature.mfcc(y=analysis_data, sr=self.sample_rate)
        # print(3)
        self.rms = librosa.feature.rms(y=analysis_data)
        # print(4)
        
    def compare_to(self, other_chunk):
        #print('1')

        # Ensure both chunks have extracted features
        if self.chroma is None or other_chunk.chroma is None:
            raise ValueError("Chroma features have not been extracted." + str(self.chroma))
        if self.mfcc is None or other_chunk.mfcc is None:
            raise ValueError("MFCC features have not been extracted.")
        if self.rms is None or other_chunk.rms is None:
            raise ValueError("RMS features have not been extracted.")

        # Set weights for each feature based on the paper
        a = 1  # Weight for chroma similarity
        b = 0.6  # Weight for MFCC distance
        q = 0.2  # Weight for RMS energy difference

        #print('2')

        # Calculate cosine similarity for Chroma features
        chroma_similarity = np.mean([1 - cosine(self.chroma[:, i], other_chunk.chroma[:, i])
                                     for i in range(min(self.chroma.shape[1], other_chunk.chroma.shape[1]))])

        #print('3')

        # Calculate Euclidean distance for MFCC features
        mfcc_distance = np.mean([euclidean(self.mfcc[:, i], other_chunk.mfcc[:, i])
                                 for i in range(min(self.mfcc.shape[1], other_chunk.mfcc.shape[1]))])

        #print('4')

        # Calculate difference in RMS energy
        rms_difference = np.abs(np.mean(self.rms) - np.mean(other_chunk.rms))

        #print('5')

        # Combine these metrics into a single similarity score using the paper's formula
        similarity_score = a * chroma_similarity - b * mfcc_distance - q * rms_difference

        #print('6')

        return similarity_score
    
def divide_into_chunks(audio, beats, sample_rate, beats_per_chunk=4):
    chunks = []
    beat_samples = [int(beat * sample_rate) for beat in beats]
    chunk_lengths = []

    # First, create chunks and calculate their lengths
    for i in range(0, len(beat_samples) - beats_per_chunk, beats_per_chunk):
        start_sample = beat_samples[i]
        end_sample = beat_samples[i + beats_per_chunk] if i + beats_per_chunk < len(beat_samples) else len(audio)
        chunk_lengths.append(end_sample - start_sample)

    # Find the minimum chunk length
    min_length_samples = min(chunk_lengths)

    # Now, create AudioChunk instances with the analysis_length set to the minimum length
    for i in range(0, len(beat_samples) - beats_per_chunk, beats_per_chunk):
        start_sample = beat_samples[i]
        end_sample = beat_samples[i + beats_per_chunk] if i + beats_per_chunk < len(beat_samples) else len(audio)

        chunk_data = audio[start_sample:end_sample]
        start_time = start_sample / sample_rate
        end_time = end_sample / sample_rate
        analysis_length = min_length_samples / sample_rate  # Convert min_length_samples back to seconds for analysis_length

        chunk = AudioChunk(start_time, end_time, chunk_data, sample_rate, analysis_length)
        if len(chunk_data) != 0:
            #print(len(chunk_data))
            chunks.append(chunk)

        #print(chunk_data)

    # if(chunks[len(chunks) - 1].audio_data[len(chunks[len(chunks) - 1].audio_data) - 1] == 0):
    #     #print('popping')
    #     chunks.pop(len(chunks) - 1)

    return chunks

def detect_loops_with_exponents_of_2(chunks, top_n=10):
    similarity_scores = []

    # Iterate through all chunks
    for i in range(len(chunks)):
        n = 2
        while True:
            j = i + 2**n  # Calculate the index of the chunk 2^n positions ahead
            if j < len(chunks) and n <= 4:  # Ensure the index is within the range of available chunks
                score = chunks[i].compare_to(chunks[j])
                similarity_scores.append((i, j, score))
                n += 1  # Move to the next exponent of 2
            else:
                break  # If j exceeds the number of chunks, stop comparing this chunk

    # Sort the similarity scores in descending order (most similar first)
    sorted_scores = sorted(similarity_scores, key=lambda x: x[2], reverse=True)

    # Return the top N scores (adjust N based on your needs)
    top_n_scores = sorted_scores[:top_n]

    return top_n_scores

def export_loop_segments(audio, sample_rate, chunks, top_scores, prefix, export_folder):
    """
    Export loop segments identified by top scoring pairs into a folder as individual audio files.

    Parameters:
    - audio: The full audio data array.
    - sample_rate: The sample rate of the audio data.
    - chunks: The list of AudioChunk objects.
    - top_scores: A list of tuples containing the indices of the first and second chunks and their similarity score.
    - export_folder: The folder where the audio segments will be exported.
    """
    # Create the export folder if it doesn't already exist
    if not os.path.exists(export_folder):
        print('creating folder')
        print(export_folder)
        os.makedirs(export_folder)

    # Iterate over the top scoring pairs and export each segment
    for i, (first_chunk_index, second_chunk_index, score) in enumerate(top_scores):
        # Calculate the sample indices for the start of the first chunk and the start of the second chunk
        start_sample = int(chunks[first_chunk_index].start_time * sample_rate)
        end_sample = int(chunks[second_chunk_index].start_time * sample_rate)
        
        # Extract the loop segment from the audio
        loop_segment = audio[start_sample:end_sample]
        
        # Define the export path for the segment
        export_path = os.path.join(export_folder, f"{score:.2f}_{prefix}_loop_{i+1}.wav")
        
        # Export the loop segment as a WAV file
        sf.write(export_path, loop_segment, sample_rate)

    print(f"Exported {len(top_scores)} loop segments to '{export_folder}'")

# sample1 = mlSample("/Users/red/Downloads/musicforemptyrooms/The Calcutta Cast - Gomaz [Netherlands] Library, Easy Listening (1971) [NG-zsXTha24].wav")
# sample1.load_sample()

crate1 = mlCrate("/Users/red/Downloads/rcx01apr25/crate/mlCrate1/")
crate1.load_samples()
crate1.load_decks()

print('no problem')