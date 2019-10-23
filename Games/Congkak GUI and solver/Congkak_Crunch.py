import copy
import gc

rows = 7
initVal = int(input("InitVal:"))
layout_length = 2*rows+1

def searchTurn(startIndex,layout):
    start = startIndex
    
    in_hand = layout[start]
    layout[start] = 0
    for i in range(in_hand):
        start = (start+1)%(layout_length)
        layout[start] += 1
        
        
    while (start!=rows and layout[start]!=1):
        in_hand = layout[start]
        layout[start] = 0
        for i in range(in_hand):
            start = (start+1)%(layout_length)
            layout[start] += 1
            
    if start<rows and layout[2*rows-start]!=0:
        layout[rows] += layout[2*rows-start]
        layout[2*rows-start] = 0
    return [start==rows,layout]

def searchRecursive(path,profit,startIndex,layout):
##don't enter if layout[startIndex]==0
    
    clone_layout = copy.deepcopy(layout)
    results = searchTurn(startIndex,clone_layout)
    global paths,profits,printCounter
    printCounter+=1
    repeat = results[0]
    layout_aft = results[1]
    path.append(startIndex)
    profit = layout_aft[rows]
    
    if(repeat):
        for i in range(rows):
            if layout_aft[i]!=0:
                searchRecursive(copy.deepcopy(path),profit,i,layout_aft)
##                 vulnerable to last step (when no moves left)
    else:
        
        if len(profits)!=0 and profit>profits[len(profits)-1]:
            paths = []
            profits = []
        elif len(profits)==0 or profit==profits[len(profits)-1]:
            paths.append(path)
            profits.append(profit)

        if(printCounter>100000):
            print("Tracing",path,"Depth:",len(path))
            printCounter = 0
    

main_layout = list(initVal for i in range(layout_length))
main_layout[rows] = 0

print(main_layout)
paths = []
profits=[]
writebuffer=[]
writebuffer2=[]

printCounter = 0
outfile = open("results.txt",'w')
for i in range(rows):
    searchRecursive([],0,i,main_layout)
    if(profits[len(profits)-1]<profits[len(profits)-2]):
        profits.pop()
        paths.pop()
    for i in range(len(paths)):
        
        writebuffer.append(paths[i])
##        for j in range(len(paths[i])):
##            
##            if j+1!=len(paths[i]):
##                outfile.write(str(paths[i][j])+',')
##            else:
##                outfile.write(str(paths[i][j]))
        writebuffer2.append(profits[i])
##        outfile.write(' '+str(profits[i]))
##        outfile.write('\n')
            
##    print(paths)
##    print(profits)
    paths = []
    profits = []
    
maxIndex = []
maxVal = 0
for i in range(1,len(writebuffer2)):    
    if writebuffer2[i]>maxVal:
        maxVal = writebuffer2[i]
        maxIndex = []
        maxIndex.append(i)
    elif writebuffer2[i]==maxVal:
        maxIndex.append(i)
##print(writebuffer)
##print(writebuffer2)
##print(maxIndex)
outfile.write("_____"+str(initVal)+"_____\n")
print("_____"+str(initVal)+"_____\n",end='')
for index in maxIndex:
    for i in range(len(writebuffer[index])):
##        print("writebuffer=",writebuffer,"writebuffer["+str(index)+"]=",writebuffer[index])
        writebuffer[index][i] = str(writebuffer[index][i])
    outfile.write(','.join(writebuffer[index]))
    print(','.join(writebuffer[index]),end='')
    print(' Profit: '+str(writebuffer2[index]))
    outfile.write(' '+str(writebuffer2[index])+'\n')
outfile.close()
input()

