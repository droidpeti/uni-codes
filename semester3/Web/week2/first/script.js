//1.
function hello(){
    console.log("Hello World!");
}

//2.
function cel_fahr(cel){
    return (cel*1.8)+32;
}

//3.
function percent(num, per){
    return num * (per/100);
}

//4.
function valid_tri(a, b, c){
    if(a + b > c  && a + c > b && c + b > a){
        return true;
    }
    return false;
}

//5.
function is_mod(a, b){
    return a % b == 0;
}

//6.
function point_location(x, y){
    if(x > 0 && y > 0){
        return "northeast";
    }
    else if(x > 0 && y < 0){
        return "southeast";
    }
    else if(x < 0 && y > 0){
        return "northwest";
    }
    else if(x < 0 && y < 0){
        return "southwest";
    }
    else if(x == 0 && y > 0){
        return "north";
    }
    else if(x == 0 && y < 0){
        return "south";
    }
    else if(x > 0 && y == 0){
        return "east";
    }
    else if(x < 0 && y == 0){
        return "west";
    }
    else{
        return "center";
    }
}

//7.
function largest_div(a, b){
    if(a < b){
        let c = a;
        a = b;
        b = c;
    }
    let remainder = a % b;
    while(remainder > 0){
        a = b;
        b = remainder;
        remainder = a % b;
    }
    return b;
}

//8.
function smallest_mult(a, b){
    let x = a;
    let y = b;
    while(x != y){
        if(x < y){
            x += a;
        }
        else if(x > y){
            y += b;
        }
    }
    return x;
}

//9.
function fact(num){
    if(num <= 1){
        return 1;
    }
    return num * fact(num-1);
}


