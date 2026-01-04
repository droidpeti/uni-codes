#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef struct{
	char* name;
	char* sector;
	int open;
	int close;
} Stock;

typedef struct{
	char* name;
	int stock_count;
	double sum_close;
} Sector;

int compare(const void* a, const void* b){
	Stock *s1 = *(Stock**)a;
	Stock *s2 = *(Stock**)b;
	if(s1->close > s2->close){
		return -1;
	}
	else if(s1->close < s2->close){
		return 1;
	}
	return 0;
}

int main(){
	char file_name[] = "stocks.txt";
	FILE *fptr = fopen(file_name, "r");
	if(fptr == NULL){
		printf("Couldn't find file!\n");
		return 1;
	}
	int count = 0;
	char buf[256];
	while(fgets(buf, sizeof(buf), fptr) != NULL){
		count++;
	}
	rewind(fptr);

	Stock *stocks = (Stock*)calloc(count, sizeof(Stock));
	if(stocks == NULL){
		printf("Memory allocation failed!\n");
		return 1;
	}

	for(int i = 0; i < count; i++){
		fgets(buf,sizeof(buf),fptr);
		buf[strcspn(buf,"\r\n")] = '\0';
		const char delimiter[] = ";";
		char *token = strtok(buf, delimiter);
		int j = 0;
		while(token != NULL){
			if(j == 0){
				stocks[i].name = strdup(token);
			}
			else if(j == 1){
				stocks[i].sector = strdup(token);
			}
			else if(j == 2){
				stocks[i].open = atoi(token);
			}
			else if(j == 3){
				stocks[i].close = atoi(token);
			}
			token = strtok(NULL, delimiter);
			j++;
		}
	}
	fclose(fptr);

	int sector_count = 0;
	Sector *sectors = NULL;
	for(int i = 0; i < count; i++){
		int contains = 0;
		for(int j = 0; j < sector_count; j++){
			if(strcmp(sectors[j].name, stocks[i].sector) == 0){
				contains = 1;
				break;
			}
		}
		if(!contains){
			Sector *tmp = (Sector*)realloc(sectors, (++sector_count)*sizeof(Sector));
			if(tmp == NULL){
				printf("Memory allocation failed!");
				for(int i = 0; i < count; i++){
						free(stocks[i].name);
						free(stocks[i].sector);
					}
				free(stocks);
				return 1;
			}
			sectors = tmp;
			sectors[sector_count-1].name = stocks[i].sector;
			sectors[sector_count-1].stock_count = 0;
			sectors[sector_count-1].sum_close = 0;
		}
	}

	for(int i = 0; i < sector_count; i++){
		for(int j = 0; j < count; j++){
			if(strcmp(sectors[i].name, stocks[j].sector) == 0){
				sectors[i].stock_count++;
				sectors[i].sum_close += stocks[j].close;
			}
		}
		printf("%s sector's stocks amount: %d\n", sectors[i].name, sectors[i].stock_count);
	}

	double max_increase = (((double)stocks[0].close/(double)stocks[0].open)*100)-100;
	Stock* max_stock = &stocks[0];

	for(int i = 1; i < count; i++){
		double cur_increase = (((double)stocks[i].close/(double)stocks[i].open)*100)-100;
		if(cur_increase > max_increase){
			max_increase = cur_increase;
			max_stock = &stocks[i];
		}
	}

	printf("The company with the highest growth for the day is: %s with %.2lf%% growth, that's %d$ per share\n", max_stock->name, max_increase, max_stock->close-max_stock->open);

	printf("Please enter a string you are searching for: ");
	scanf("%s", buf);

	for(int i = 0; i < count; i++){
		if(strstr(stocks[i].name, buf) != NULL){
			printf("%s contains the substring %s\n", stocks[i].name, buf);
		}
	}

	for(int i = 0; i < sector_count; i++){
		printf("%s sector's average close price is: %.2lf\n", sectors[i].name, sectors[i].sum_close/(double)sectors[i].stock_count);
	}

	char search_sector[] = "Tech";
	int search_count = 0;
	for(int i = 0; i < sector_count; i++){
		if(strcmp(sectors[i].name, search_sector) == 0){
			search_count = sectors[i].stock_count;
			break;
		}
	}

	Stock **searched_stocks = (Stock**)malloc(sizeof(Stock*)*search_count);
	int k = 0;
	for(int i = 0; i < count; i++){
		if(strcmp(stocks[i].sector, search_sector) == 0){
			searched_stocks[k++] = &stocks[i];
			if(k >= search_count){
				break;
			}
		}
	}

	qsort(searched_stocks, search_count, sizeof(Stock*), compare);

	printf("%s sector's stocks in descending order by close price\n", search_sector);
	for(int i = 0; i < search_count; i++){
		printf("%s: %d$\n", searched_stocks[i]->name, searched_stocks[i]->close);
	}

	free(searched_stocks);
	free(sectors);
	for(int i = 0; i < count; i++){
		free(stocks[i].name);
		free(stocks[i].sector);
	}
	free(stocks);
	
	return 0;
}
