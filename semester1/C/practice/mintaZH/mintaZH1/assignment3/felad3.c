#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <float.h>

typedef struct{
    char* model;
    char* manufacturer;
    double price;
} Laptop;

typedef struct{
    char* name;
    int laptop_count;
    double price_sum;
    char* most_expensive_model;
    double most_expensive_price;
} Manufacturer;

int compareLaptopsDesc(const void* a, const void* b){
        Laptop* l1 = *(Laptop**)a;
        Laptop* l2 = *(Laptop**)b;
        if(l2->price > l1->price) return 1;
        if(l2->price < l1->price) return -1;
        return 0;
    }

int main(){
    char file_name[] = "laptops.txt";
    FILE *fptr = fopen(file_name, "r");
    if(fptr == NULL){
        printf("Failed to open file, exiting...\n");
        return 1;
    }

    char buff[256];

    int count = 0;
    while(fgets(buff, sizeof(buff), fptr) != NULL){
        count++;
    }
    rewind(fptr);

    Laptop *laptops = (Laptop*)calloc(count, sizeof(Laptop));
    if(laptops == NULL){
        printf("Memory allocation failed!\n");
        return 1;
    }

    for(int i = 0; i < count; i++){
        fgets(buff, sizeof(buff), fptr);
        buff[strcspn(buff, "\r\n")] = '\0';
        const char delimiter[] = ";";
        char *token = strtok(buff,delimiter);
        int j = 0;
        while(token != NULL){
            if(j == 0){
                laptops[i].model = strdup(token);
            }
            else if(j == 1){
                laptops[i].manufacturer = strdup(token);
            }
            else if(j == 2){
                laptops[i].price = atof(token);
            }
            token = strtok(NULL, delimiter);
            j++;
        }
    }
    fclose(fptr);

    int unq_man_count = 0;
    Manufacturer* unique_manufacturers = NULL;

    for(int i = 0; i < count; i++){
        int contains = 0;
        for(int j = 0; j < unq_man_count; j++){
            if(strcmp(laptops[i].manufacturer, unique_manufacturers[j].name) == 0){
                contains = 1;
            }
        }
        if(!contains){
            Manufacturer* temp = realloc(unique_manufacturers, sizeof(Manufacturer) * (++unq_man_count));
            if(temp == NULL){
                printf("Memory reallocation failed!\n");
                for(int i = 0; i < count; i++){
                    free(laptops[i].model);
                    free(laptops[i].manufacturer);
                }
                free(laptops);
                return 1;
            }
            unique_manufacturers = temp;
            unique_manufacturers[unq_man_count-1].name = laptops[i].manufacturer;
        }
    }

    printf("Unique Manufacturers, and their laptop count:\n");
    for(int i = 0; i < unq_man_count; i++){
        unique_manufacturers[i].laptop_count = 0;
        unique_manufacturers[i].price_sum = 0;
        unique_manufacturers[i].most_expensive_price = -DBL_MAX;
        for(int j = 0; j < count; j++){
            if(strcmp(laptops[j].manufacturer, unique_manufacturers[i].name) == 0){
                unique_manufacturers[i].laptop_count++;
                unique_manufacturers[i].price_sum += laptops[j].price;
                if(laptops[j].price > unique_manufacturers[i].most_expensive_price){
                    unique_manufacturers[i].most_expensive_price = laptops[j].price;
                    unique_manufacturers[i].most_expensive_model = laptops[j].model;
                }
            }
        }
        printf("%s's laptops: %d piece(s)\n", unique_manufacturers[i].name, unique_manufacturers[i].laptop_count);
    }

    double price_sum = 0;
    for(int i = 0; i < count; i++){
        price_sum += laptops[i].price;
    }
    printf("Overall average price: %.2lf HUF\n", price_sum/(double)count);

    for(int i = 0; i < unq_man_count; i++){
        printf("%s's average price: %.2lf HUF\n", unique_manufacturers[i].name, unique_manufacturers[i].price_sum/(double)unique_manufacturers[i].laptop_count);
    }

    for(int i = 0; i < unq_man_count; i++){
        printf("%s's most expensive model: %s\n", unique_manufacturers[i].name, unique_manufacturers[i].most_expensive_model);
    }

    double num;
    printf("Please input a number: ");
    scanf("%lf", &num);

    for(int i = 0; i < count; i++){
        if(num > laptops[i].price){
            printf("%s %s is cheaper than %.2lf HUF\n", laptops[i].manufacturer, laptops[i].model, num);
        }
    }

    if (unq_man_count > 0) {
        char* target_man = unique_manufacturers[unq_man_count - 1].name;
        printf("%s's products in descending order\n", target_man);

        int count_last = unique_manufacturers[unq_man_count - 1].laptop_count;
        Laptop** sorted_laptops = malloc(count_last * sizeof(Laptop*));
        
        int k = 0;
        for(int i = 0; i < count; i++){
            if(strcmp(laptops[i].manufacturer, target_man) == 0){
                sorted_laptops[k++] = &laptops[i];
            }
        }

        qsort(sorted_laptops, count_last, sizeof(Laptop*), compareLaptopsDesc);

        for(int i = 0; i < count_last; i++){
            printf("%s: %.0f HUF\n", sorted_laptops[i]->model, sorted_laptops[i]->price);
        }
        
        free(sorted_laptops);
    }

    free(unique_manufacturers);
    for(int i = 0; i < count; i++){
        free(laptops[i].model);
        free(laptops[i].manufacturer);
    }

    free(laptops);

    return 0;
}
