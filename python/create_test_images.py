from keras.datasets import mnist

def write_image(name, a, header_file):
   header_file.write("  unsigned char " + name + "[28][28] = { \n")
   for row in range(a.shape[0]):
     header_file.write("         { ");
     for col in range(a.shape[1]):
        if (a[row][col]>0):
           header_file.write("0x{:02x}".format(a[row][col]))
        else :
           header_file.write("   0");
        if (col < a.shape[1]-1):
           header_file.write(", ")
     if (row < a.shape[0]-1):
        header_file.write(" }, \n");
     else:
        header_file.write(" }  \n");
   header_file.write("     }; \n")

def number_string(i):
   if (i == 0): 
      return "zero"
   if (i == 1): 
      return "one"
   if (i == 2):
      return "two"
   if (i== 3):
      return "three"
   if (i == 4):
      return "four"
   if (i == 5):
      return "five"
   if (i == 6):
      return "six"
   if (i == 7):
      return "seven"
   if (i == 8):
      return "eight"
   if (i == 9):
      return "nine"
   return None


def write_test_images():
   header_file = open("test_images.h", "w")

   (xtrain, ytrain), (xtest, ytest) = mnist.load_data()

   for num in range(10):
      i = 0
      while (ytrain[i] != num) :
         i = i + 1
      write_image(number_string(ytrain[i]), xtrain[i], header_file)

   header_file.close()

if __name__ == '__main__':
   write_test_images()

