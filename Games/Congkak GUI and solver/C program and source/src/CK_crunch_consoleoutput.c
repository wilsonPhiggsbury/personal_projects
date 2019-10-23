#include <stdio.h>
#include <stdlib.h>
#define ROWS 7
#define ULONG_MAX 9223372036854775807
#define INT_MAX 2147483647
#define INT_MIN -2147483648
#define PRINT_INTERVAL 20000000
#define DEPTH_LIMIT 80

struct Path
{
	short path[DEPTH_LIMIT];
	short profit;
};
struct PathNode
{
	struct Path pathStruct;
	struct PathNode *next;
};
struct Layout
{
	short layout[ROWS*2 + 2];
	short startIndex;
};
// function prototypes
void search_recursive(struct Path*,struct Layout*,short);
void searchTurn(struct Layout*);
void appendPath(struct Path*);
struct Path * readPath(int);
void clearPath();
// global variables
struct PathNode *head,*temp;
short highest_profit;
int printCounter,printCounterMagnitude2;

void main()
{
	highest_profit = 0;
	printCounterMagnitude2 = 0;
	printCounter = 0;
	// n=[-32768,32767]
	short n,i;
	printf("Starting Marbles in each square: ");
	scanf("%d",&n);

	struct Path initPath;
	struct Layout initLayout;
	for (i=0; i<ROWS*2+2; i++)
	{
		initLayout.layout[i] = n;
	}
	initLayout.layout[ROWS] = initLayout.layout[2*ROWS+1] = 0;
	//global variable: linkedlist array "paths", int "highest profit"
	//starting variable: initial struct Layout
	for (i=0; i<ROWS; i++)
	{
		initLayout.startIndex = i;
		search_recursive(&initPath,&initLayout,0);
	}
	// generate report
	unsigned long total = 0;
	printf("\n_____________________________________BEST MOVES REPORT_____________________________________\n");
	printf("\n____________%d____________\n",n);

	
	temp = head;
	printf("Best Profit: %d\n",temp->pathStruct.profit);
	printf("\nBest Solutions: \n");
	do
	{
		i=0;
		printf("[");
		// facilitate printing with terminating value ROWS
		while(temp->pathStruct.path[i+1]!=ROWS)
		{
			printf("%d,",temp->pathStruct.path[i++]);
		}
		printf("%d",temp->pathStruct.path[i++]);
		// end of printing array
		printf("]\n");
		temp = temp->next;
		total++;
	}while(temp!=NULL);
	
	printf("\nThere are %lu best solutions in total.",total);
	total = PRINT_INTERVAL*printCounterMagnitude2 + printCounter;
	printf("\nChecks ran: %lu\nDoes not include moves starting from zero square(invalid).\n",total);
	printf("\n_______________________________________END OF PROGRAM_______________________________________\n");
	scanf("%d",&printCounterMagnitude2);
}
void search_recursive(struct Path *path, struct Layout *layout, short depth)
{
	printCounter++;
	// Directory:
	// paths.path (short array)
	// paths.profit (short)
	// layout.layout (short array)
	// layout.startIndex (short)

	//0. <CLONE>
	short i;
	struct Path *clonePath = malloc(sizeof(struct Path));
	struct Layout *cloneLayout = malloc(sizeof(struct Layout));
	*clonePath = *path;
	*cloneLayout = *layout;
	
	//1. <APPEND>
	clonePath->path[depth] = cloneLayout->startIndex;
	//2. <ALTER>
	searchTurn(cloneLayout);
	//3. <UPDATE>
	clonePath->profit = cloneLayout->layout[ROWS];
	//4. <BRANCH>
	// print progress
	if(printCounter==PRINT_INTERVAL)//INT_MAX)
	{
		printCounter = 0;
		printCounterMagnitude2++;
		printf("Searching [");
		for(i=0;i<depth;i++)
		{
			printf("%d,",clonePath->path[i]);
		}
		printf("%d",clonePath->path[depth]);
		printf("]");
		if(depth<DEPTH_LIMIT)
			printf(" Depth: %d\n",depth);
		else
		{
			printf(" Crash! Define a bigger array for Path.path!");
			scanf("%d",&printCounter);
			exit(0);
		}
	}
	if(cloneLayout->startIndex == ROWS)
		for(i=0;i<ROWS;i++)
		{
			cloneLayout->startIndex = i;
			// only search when you have something to grab
			if(cloneLayout->layout[cloneLayout->startIndex]!=0)
				search_recursive(clonePath,cloneLayout,depth+1);
		}
	else
	{
		if(clonePath->profit < highest_profit)
		{
			
		}
		else if(clonePath->profit > highest_profit)
		{
			highest_profit = clonePath->profit;
			printf("New highest profit found: %d\n",highest_profit);
			// insert a terminating number 7 to facilitate printing later in main()
			clonePath->path[depth+1] = ROWS;
			clearPath();
			appendPath(clonePath);
			//printf("PUSHED 1\n");
		}
		else
		{
			clonePath->path[depth+1] = ROWS;
			appendPath(clonePath);
			//printf("PUSHED 1\n");
		}
	}
	//END. <DESTROY CLONE>
	free(clonePath);
	free(cloneLayout);


	/*Pseudo-Code for search_recursive()

	<CLONE> Path structure
	<CLONE> Layout structure

	1.<APPEND> cloneLayout.startIndex to clonePath.path
	2.<ALTER> cloneLayout by chugging into searchTurn(cloneLayout)
	3.<UPDATE> clonePath.profit from new value of cloneLayout.layout[7]
	NOTE: cloneLayout WILL BE ALTERED!

	4.<BRANCH> if result Layout.startIndex == 7 then repeat
	if repeat,
		<LOOP 7 times> i=[0,6]

			<UPDATE> cloneLayout.startIndex with loop iteration, stimulates all search decisions
			<RECURSIVE> search_recursive() using the resulting layout and clonePath, depth+1
			
	else
		on the end of branching tree:(will not trigger on non-ends)

		if this new profit > old profit
			<CLEAR> paths array, set this path to first element
			<UPDATE> the old profit to this profit
		if this new profit < old profit
			-
		if this new profit == old profit OR paths empty
			<APPEND> this path into paths array

	<DESTROY CLONE> clonePath
	<DESTROY CLONE> cloneLayout*/

}
void searchTurn(struct Layout *layout)
{
	short in_hand;
	short i;
	short startIndex = layout->startIndex;
	do
	{
		// these 2 lines resemble "grab" in congkak
		in_hand = layout->layout[startIndex];
		layout->layout[startIndex] = 0;
		// this loop resemble dropping one by one
		for(i=0;i<in_hand;i++)
		{
			startIndex++;
			// sequence range is [0,14]
			// skip the last big house from top player's perspective
			if(startIndex==2*ROWS+1)
				startIndex = 0;
			layout->layout[startIndex]++;
		}
		// grab again? when not landing on home, and not landing on empty
	}while(startIndex!=ROWS && layout->layout[startIndex]>1);
	// eat adjacent squares if land on self territory
	if(startIndex<ROWS && startIndex!=ROWS && layout->layout[startIndex]==1)
	{
		layout->layout[ROWS] += layout->layout[2*ROWS-startIndex];
		//printf("Ate %d marbles! Score: %d\n",layout->layout[2*ROWS-startIndex],layout->layout[ROWS]);
		layout->layout[2*ROWS-startIndex] = 0;
	}
	// alter startIndex for checking bonus turn use in the calling function
	layout->startIndex = startIndex;
	// goes round and round until you land on an empty square
	// alters Layout in calling function: repeat,result layout (is actually a short array)
}
void appendPath(struct Path *path)
{
	if(head==NULL)
	{
		head = malloc(sizeof(struct PathNode));
		temp = head;
	}
	else
	{
		temp->next = malloc(sizeof(struct PathNode));
		temp = temp->next;
	}
	temp->pathStruct = *path;
	temp->next = NULL;
}
struct Path * readPath(int index)
{
	struct PathNode *node = head;
	int i;
	for(i=0;i<index;i++)
	{
		node = node->next;
	}
	return &(node->pathStruct);
}
void clearPath()
{
	temp = head;
	while(temp!=NULL)
	{
		struct PathNode *ptr = temp->next;
		free(temp);
		temp = ptr;//printf("POPPED 1\n");
	}
	head = NULL;
}