/*
    CPSC355 Project Part I
    By Haipeng Qiao
*/

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

struct cell
{
    float points;
    int scoreDoubled;
    int scoreHalved;
    int extraTime;
    int covered;
    int ready;
};

/*
    input: lower bound n, top bound m, negative if neg = 1
    output: a random integer inclusively between n and m, with intended sign
*/
int randomNum(int n, int m, int neg)
{
    int power = 1;
    while(power < (m - n + 1))
    {
        power = power << 1;
    }
    int result = (rand() & (power - 1)) + n;
    if(result > m)
    {
        result -= m;
    }
    if(neg == 1)
    {
        return -result;
    }
    return result;
}

/*
    input: pointer to cell matrix, size of the square matrix
    output: void
    function: fill in the matrix with cell, and each cell has properties like points, surprise, covered, etc.
*/
void initializeGame(struct cell *board, int size)
{
    int i, j, k;
    for(i = 0; i < size; i++)
    {
        for(j = 0; j < size; j++)
        {
            (*((board + i * size) + j)).scoreDoubled = 0;
            (*((board + i * size) + j)).scoreHalved = 0;
            (*((board + i * size) + j)).extraTime = 0;
            (*((board + i * size) + j)).covered = 1;
            (*((board + i * size) + j)).ready = 0;
        }
    }
    srand(time(NULL));
    for(i = 0; i < 3 * (size / 5) ; i++)
    {
        do
        {
            j = randomNum(0, size - 1, 0);
            k = randomNum(0, size - 1, 0);
        }
        while((*((board + j * size) + k)).ready == 1);
        if(i >= 0 && i < 1 * (size / 5))
        {
            (*((board + j * size) + k)).scoreDoubled = 1;
        }
        else if(i >= 1 * (size / 5) && i < 2 * (size / 5))
        {
            (*((board + j * size) + k)).scoreHalved = 1;
        }
        else
        {
            (*((board + j * size) + k)).extraTime = 1;
        }
        (*((board + j * size) + k)).ready = 1;
    }
    for(i = 0; i < size * size / 5 ; i++)
    {
        do
        {
            j = randomNum(0, size - 1, 0);
            k = randomNum(0, size - 1, 0);
        }
        while((*((board + j * size) + k)).ready == 1);
        (*((board + j * size) + k)).points = randomNum(1, 1500, 1) * 0.01;
        (*((board + j * size) + k)).ready = 1;
    }
    for(i = 0; i < size; i++)
    {
        for(j = 0; j < size; j++)
        {
            if((*((board + i * size) + j)).ready == 0)
            {
                (*((board + i * size) + j)).points = randomNum(1, 1500, 0) * 0.01;
                (*((board + i * size) + j)).ready = 1;
            }
        }
    }
}

/*
    input: pointer to cell matrix, size of the square matrix
    output: void
    function: display the matrix based on each cell's properties.
*/
void displayGame(struct cell *board, int size)
{
    int i, j;
    for(i = -1; i < size; i++)
    {
        for(j = -1; j < size; j++)
        {
            if(i == -1 && j == -1)
            {
                printf("   ");
            }
            else if(i == -1)
            {
                printf("%2d ", j);
            }
            else if(j == -1)
            {
                printf("%2d ", i);
            }
            else if((*((board + i * size) + j)).covered == 1)
            {
                printf(" X ");
            }
            else if((*((board + i * size) + j)).scoreDoubled == 1)
            {
                printf(" $ ");
            }
            else if((*((board + i * size) + j)).scoreHalved == 1)
            {
                printf(" ! ");
            }
            else if((*((board + i * size) + j)).extraTime == 1)
            {
                printf(" @ ");
            }
            else if((*((board + i * size) + j)).points < 0)
            {
                printf(" - ");
            }
            else
            {
                printf(" + ");
            }
        }
        printf("\n");
    }
}

/*
    input: pointer to cell matrix, size of the square matrix, row and column indices currently uncovered, current score
    output: updated score considering the newly uncovered cell
*/
float calculateScore(struct cell *board, int size, int rowIndex, int columnIndex, float score)
{
    if((*((board + rowIndex * size) + columnIndex)).scoreDoubled == 1)
    {
        int intScore = (int) (score * 100);
        score = ((float) (intScore << 1)) / 100;
        printf("Wow, score doubled\n");
    }
    else if((*((board + rowIndex * size) + columnIndex)).scoreHalved == 1)
    {
        int intScore = (int) (score * 100);
        score = ((float) (intScore >> 1)) / 100;
        printf("Oh, score halved\n");
    }
    else if((*((board + rowIndex * size) + columnIndex)).points == 1)
    {
        score += (*((board + rowIndex * size) + columnIndex)).points;
        printf("Oh, %.2f points lost\n", -(*((board + rowIndex * size) + columnIndex)).points);
    }
    else
    {
        score += (*((board + rowIndex * size) + columnIndex)).points;
        printf("Wow, %.2f points added\n", (*((board + rowIndex * size) + columnIndex)).points);
    }
    return score;
}

/*
    input:
    output: void
    function: print and sort the name, score (1st factor) and time used (2nd factor) into the log file
*/
void logScore(char *name, float score, long int duration, long int remainingTime, FILE *fptr)
{
//    int usedTime = (int) (duration - remainingTime);
//    int lineCounts = 0;
//    char c;
//    while(!feof(fptr))
//    {
//        c = fgetc(fptr);
//        if(c == '\n')
//        {
//            lineCounts++;
//        }
//    }
//    if(lineCounts <= 1)
//    {
//        fprintf(fptr, "%15s %10s %15s\n", "Name", "Score", "Time Used");
//        fprintf(fptr, "%15s %10.2f %15d\n", name, score, usedTime);
//    }
//    else
//    {
//        int i = 0;
//        char names[lineCounts - 1][15];
//        float scores[lineCounts - 1];
//        int usedTimes[lineCounts - 1];
//        int inserted = 0;
//        do
//        {
//            c = fgetc(fptr);
//        }
//        while (c != '\n');
//        while(!feof(fptr))
//        {
//            fscanf(fptr, "%s %f %d", &names[i][0], &scores[i], &usedTimes[i]);
//            i++;
//        }
//        fprintf(fptr, "%15s %10s %15s\n", "Name", "Score", "Time Used");
//        for(i = 0; i < lineCounts - 1; i++)
//        {
//            if(inserted == 1 || (scores[i] - score) >= 0.01)
//            {
//                fprintf(fptr, "%15s %10.2f %15d\n", names[i], scores[i], usedTimes[i]);
//            }
//            else if((score - scores[i]) >= 0.01)
//            {
//                fprintf(fptr, "%15s %10.2f %15d\n", name, score, usedTime);
//                fprintf(fptr, "%15s %10.2f %15d\n", names[i], scores[i], usedTimes[i]);
//                inserted = 1;
//            }
//            else if(usedTime < usedTimes[i])
//            {
//                fprintf(fptr, "%15s %10.2f %15d\n", name, score, usedTime);
//                fprintf(fptr, "%15s %10.2f %15d\n", names[i], scores[i], usedTimes[i]);
//                inserted = 1;
//            }
//            else if(usedTime > usedTimes[i])
//            {
//                fprintf(fptr, "%15s %10.2f %15d\n", names[i], scores[i], usedTimes[i]);
//            }
//        }
//        if(inserted == 0)
//        {
//            fprintf(fptr, "%15s %10.2f %15d\n", name, score, usedTime);
//        }
//    }
//    fclose(fptr);
}

//void exitGame()
//{
//}
//
//void displayTopScores(n)
//{
//}

int main(int argc, char *argv[])
{
    char *name = argv[1];
    int n = atoi(argv[2]);
    int coveredNums = n * n;
    time_t startTime;
    long int duration = coveredNums * 60 / 25;
    long int remainingTime = duration;
    float score = 0.00;
    struct cell board[n][n];
    initializeGame((struct cell*)board, n);
    int row, column;
    do
    {
        displayGame((struct cell*)board, n);
        printf("Score: %.2f\n", score);
        printf("Time: %ld\n\n", remainingTime);
        do
        {
            printf("Enter the cell to uncover (row column): ");
            scanf("%d %d", &row, &column);
        }
        while(board[row][column].covered == 0);
        if(coveredNums == n * n)
        {
            startTime = time(NULL);
        }
        printf("\n");
        board[row][column].covered = 0;
        coveredNums -= 1;
        if(board[row][column].extraTime == 1)
        {
            remainingTime += 10;
            printf("Wow! 10s added\n");
        }
        else
        {
            score = calculateScore((struct cell*)board, n, row, column, score);
        }
        remainingTime -= (long int) (time(NULL) - startTime);
    }
    while(coveredNums > 0 && remainingTime > 0 && (score > 0 || coveredNums == n * n - 1));
    if(coveredNums == 0)
    {
        printf("Congratulations! All cells are uncovered.\n");
    }
    else if(remainingTime <= 0)
    {
        printf("Sorry, time is up.\n");
    }
    else
    {
        printf("Sorry, the score drops below zero.\n");
    }
    FILE *fptr;
    fptr = fopen("l5.log", "a+");
    if(fptr == NULL)
    {
        printf("Error!");
        exit(1);
    }
    logScore((char*)name, score, duration, remainingTime, fptr);
    return 0;
}
