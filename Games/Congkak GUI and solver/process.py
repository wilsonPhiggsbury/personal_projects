write = open("5_best_moves_top.txt",'w')

read = open("5_best moves.txt",'r')

newlist = []
for i in read:
    newlist.append(i.split(','))

for line in newlist:
    for i in range(len(line)):
        line[i] = str(int(line[i])-7)
        if i+1!=len(line):
            write.write(line[i]+',')
        else:
            write.write(line[i])
    write.write('\n')
write.close()
print(",".join(line))

