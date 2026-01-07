//                  ___           ___                       ___     
//                 /\  \         /\__\          ___        /\  \    
//                /::\  \       /:/  /         /\  \      /::\  \   
//               /:/\ \  \     /:/__/          \:\  \    /:/\:\  \  
//              _\:\~\ \  \   /::\  \ ___      /::\__\  /::\~\:\  \ 
//             /\ \:\ \ \__\ /:/\:\  /\__\  __/:/\/__/ /:/\:\ \:\__\
//             \:\ \:\ \/__/ \/__\:\/:/  / /\/:/  /    \/__\:\/:/  /
//              \:\ \:\__\        \::/  /  \::/__/          \::/  / 
//               \:\/:/  /        /:/  /    \:\__\           \/__/  
//                \::/  /        /:/  /      \/__/                  
//                 \/__/         \/__/                              

//███████╗██╗  ██╗██╗██████╗ 
//██╔════╝██║  ██║██║██╔══██╗
//███████╗███████║██║██████╔╝
//╚════██║██╔══██║██║██╔═══╝ 
//███████║██║  ██║██║██║     
//╚══════╝╚═╝  ╚═╝╚═╝╚═╝    

/*   ┌─┐┬ ┬┬┌─┐
     └─┐├─┤│├─┘
     └─┘┴ ┴┴┴     */
     
     
int wrap(int value, int start, int end) {
  int range = end - start;
  if (range <= 0) return start; // Prevent division by zero or negative ranges
  
  // Adjust the value relative to the start of the range, apply modulo, then offset back
  int wrappedValue = (value - start) % range;
  if (wrappedValue < 0) {
    wrappedValue += range; // Ensure positive wrap-around
  }
  return wrappedValue + start;
}
