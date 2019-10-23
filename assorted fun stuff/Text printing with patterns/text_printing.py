import math
import random
import time
def printBigSentence(sentence,n,character,screenSize=100):
    if sentence=='':
        sentence = randLine(open("word_list_common.txt",'r')).lower()
    if(n==''):
        n = screenSize//len(sentence)
    else:
        n = int(n)
    if n%2==0:n-=1
    if(character==''):
        character = chr(random.randint(33,126))
    
    #print("Invalid character length, printing respective character instead" if invalidChar else "Printing with character "+character)
    #print("Character width:",n)
    print()
    charOffset=0
    for y in range(0,n):
        for char in sentence:
            tempchar = character[charOffset:charOffset+1]
            charOffset += 1
            charOffset %= len(character)
            for x in range(0,n):
                if charRules(char,y,n,x):
                    print(tempchar,end='')
                else:
                    print(" ",end='')
            for spaces in range(1+math.floor(n/10)):
                # more spacing for bigger fonts
                print(" ",end='')
        time.sleep(0.05)
        print()
    
def charRules(char,y,n,x):
    half = n/2-.5
    end = n-1
    # smooth corner vector transformation
    # 2  3  5  6  8  9  11
    # 3  5  7  9  11 13 15

    # end-+curvature+y  or  -+curvature-y OR end-+corner-y or -+corner+y
    # corner offset
    corner = math.floor(0.5+1.5*end/2)
    # curve constant
    curvature = math.floor(n/4)
#    1        2       3
    #        #      #
     #        #      #
     #         #      #
     #         #       #
     #         #       #
     #         #       #
     #         #      #
     #        #      #
    #        #      #       200
    return {\
        'a':x==math.floor(end/2-y/2) or x==math.ceil(half+y/2) or (y==(half if (n-1)%4==0 else half+1) and x>(end-y)/2 and x<half+y/2),\
        'b':x==0 or (y==0 or y==half or y==end) and x<end-curvature or (x==end+round(n/4)-y or x==round(n/4)+y) and x>=corner or x==corner+y or x==end+corner-y,\
        'c':x==end-corner-y or x==-corner+y or x==0 and y>curvature and y<end-curvature or (y==0 or y==end) and x>curvature,\
        'd':x==0 or x==corner+y or x==end+corner-y or (y==0 or y==end) and x<end-curvature or x==end and y>curvature and y<end-curvature,\
        'e':x==0 or y==0 or y==half or y==end,\
        'f':x==0 or y==0 or y==half,\
        'g':x==end-corner-y or x==corner+y or x==end+corner-y or x==-corner+y or (y==0 or y==end) and x>curvature and x<end-curvature or x==0 and y>curvature and y<end-curvature or x==end and y>=half and y<end-curvature or y==half and x>half,\
        'h':x==0 or x==end or y==half,\
        'i':x==half or (y==0 or y==end) and x>=curvature and x<=end-curvature,\
        'j':y==0 or x==half and y<corner or x==end+round(n/4)-y and y>=corner or x==-corner+y,\
        'k':x==0 or x==-half*2+y*2 or x==end*2-half*2-y*2,\
        'l':x==0 or y==end,\
        'm':((x==math.ceil(y/2)) ^ (x==math.floor(end/2+half-y/2))) or x==0 or x==end,\
        'n':x==0 or x==end or x==y,\
        'o':x==end-corner-y or x==corner+y or x==end+corner-y or x==-corner+y or (x==0 or x==end) and y>curvature and y<end-curvature or (y==0 or y==end) and x>curvature and x<end-curvature,\
        'p':x==0 or (y==0 or y==half) and x<end-curvature or x==end+round(n/4)-y and x>corner or x==corner+y,\
        'q':x==end-corner-y or x==corner+y or x==end+corner-y or x==-corner+y or (x==0 or x==end) and y>curvature and y<end-curvature or (y==0 or y==end) and x>curvature and x<end-curvature or x==y and y>half,\
        'r':x==0 or (y==0 or y==half) and x<end-curvature or x==end+round(n/4)-y and x>corner or x==corner+y or x==-half*2+y*2,\
        's':x==0 and y>curvature and y<half-curvature or x==end and y>half+curvature and y<end-curvature or (y==0 or y==half or y==end) and x>curvature and x<end-curvature or x==end-corner-y or x==corner+y or x==end+corner-y or x==-corner+y or x==-round(n/4)+y and x<curvature or x==round(n/4)+y and x>end-curvature,\
        't':x==half or y==0,\
        'u':(x==0 or x==end) and y<end-curvature or y==end and x>curvature and x<end-curvature or x==end+corner-y or x==-corner+y,\
        'v':x==math.ceil(y/2) or x==math.floor(end/2+half-y/2),\
        'w':x==math.floor(y/4) or x==math.floor(half+y/4) or x==math.ceil(end-y/4) or x==math.ceil(end-half-y/4),\
        'x':x==y or x==end-y,\
        'y':(x==y or x==end-y) and y<half or x==half and y>=half,\
        'z':x==end-y or y==0 or y==end,\
        ' ':False,\
        "'":x==end-half-y and x>half/2,\
        }[char]
def randLine(file):
    file.seek(0)
    return random.choice(file.readlines())[0:-1]
print("""Input text to be printed out in big symbols, the size N of each alphabet and the character you want to use.
Leaving inputs blank makes computer auto determine them.
A random word and symbol , and a screen-friendly size will be chosen.

Type "auto" for a geeky screensaver...
""")
auto = False
screen = 100
while True:
    text = input("Text: ").lower()
##    printBigSentence(text,input("N: "),input("Char: "),screen)
    try:
        printBigSentence(text,input("N: "),input("Char: "),screen)
    except:
        print("Invalid character in text string or invalid number input.")
    if(text=='auto' or text=='automate' or text=='automatic' or text=='auto on'):
        auto=True
        print("Auto mode initiated. Prepare for WORDS!!")
        time.sleep(2)
    elif(text=='exit' or text=='scram' or text=='terminate'):
        print("Terminating...")
        time.sleep(1)
        break
    elif text=='fullscreen':
        print("Gone fullscreen!")
        screen  = 150
    elif text=='half screen':
        print("Half screen!")
        screen  = 100
    elif text=='small screen':
        print("Gone small screen!")
        screen  = 50
    while auto:
        printBigSentence('','','',screen)
        time.sleep(0.05)

##    try:
##        printBigSentence(input("Text: ").lower())
##    except:
##        print("Error! Eject!!")
##        break
