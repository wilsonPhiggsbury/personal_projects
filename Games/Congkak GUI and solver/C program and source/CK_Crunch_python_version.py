import copy
import gc

rows = 7
initVal = 6
layout_length = 2*rows+1

def searchTurn(startIndex,layout):
    start = startIndex
    
    in_hand = layout[start]
    layout[start] = 0
    for i in range(in_hand):
        start = (start+1)%(layout_length)
        layout[start] += 1
##    print(layout,layout[rows])   
        
        
    while (start!=rows and layout[start]!=1):
        in_hand = layout[start]
        layout[start] = 0
        for i in range(in_hand):
            start = (start+1)%(layout_length)
            layout[start] += 1
##        print(layout,layout[rows])
    if start<rows and layout[2*rows-start]!=0:
        layout[rows] += layout[2*rows-start]
        layout[2*rows-start] = 0
    return [start==rows,layout]
def searchRecursive(path,profit,startIndex,layout):
##don't enter if layout[startIndex]==0
    clone_layout = copy.deepcopy(layout)
    results = searchTurn(startIndex,clone_layout)
    global paths,profits
    repeat = results[0]
    layout_aft = results[1]
    path.append(startIndex)
    profit += layout_aft[rows]
    
    if(repeat):
        for i in range(rows):
            if layout_aft[i]!=0:
                searchRecursive(copy.deepcopy(path),profit,i,layout_aft)
                ## vulnerable to last step (when no moves left)
    else:
        
        if len(profits)!=0 and profit>profits[len(profits)-1]:
            paths = []
            profits = []
        elif len(profits)==0 or profit==profits[len(profits)-1]:
            paths.append(path)
            profits.append(profit)

        if(len(path)<20):
            print("Examining",path,"Best:",paths[len(paths)-1],"with profit",profits[len(profits)-1])
    
##                path = results[0]
##                profit = results[1]
##                startIndex = results[2]
##                layout_aft = results[3]
        
##    return [path,profit,startIndex,layout_aft]
        
#def search(layout):
    
# home index = row

main_layout = list(initVal for i in range(layout_length))
main_layout[rows] = 0
##main_layout[0] = 0
print(main_layout)
paths = []
profits=[]
outfile = open("results.txt",'w')
for i in range(rows):
    searchRecursive([],0,i,main_layout)
    if(profits[len(profits)-1]<profits[len(profits)-2]):
        profits.pop()
        paths.pop()
    for path in paths:
        for j in range(len(path)):
            if j+1!=len(path):
                outfile.write(str(path[j])+',')
            else:
                outfile.write(str(path[j]))
        outfile.write('\n')
            
    print(paths)
    print(profits)
    paths = []
    profits = []
outfile.close()

