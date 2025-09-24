#include <stdio.h>

int main(){
    int points_length = 8;
    double points[points_length]; // x1,y1,x2,y2,x3,y3,x4,y4

    for(int i = 0; i < points_length; i++){
        printf("Input the %c coordinate of point number %d: ", (i+1)&1 ? 'x' : 'y', (i+2)/2);
        scanf("%lf", &points[i]);
    }

    // m = (y2 - y1) / (x2 - x1)
    double slope1 = (points[3] - points[1]) / (points[2] - points[0]);
    double slope2 = (points[7] - points[5]) / (points[6] - points[4]);

    if(slope1 * slope2 == -1.0)
    {
        printf("These two lines are perpendicular");
    }
    else if(slope1 == slope2){
        printf("These two lines are paralell");
    }
    else{
        printf("These two lines are neither perpendicular or paralell");
    }
    printf("\n");
    return 0;
}