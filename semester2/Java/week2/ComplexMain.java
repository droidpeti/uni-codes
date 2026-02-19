package semester2.Java.week2;

class Complex{
    double re;
    double im;

    public double abs(){
        return Math.sqrt(Math.pow(re, 2) + (Math.pow(im, 2)));
    }

    public void add(Complex c){
        re += c.re;
        im += c.im;
    }

    public void sub(Complex c){
        re -= c.re;
        im -= c.im;
    }

    public void mul(Complex c){
        re *= c.re;
        im *= c.im;
    }

    public void printComp(){
        System.out.println(re + " + " + im + "i");
    }
}

public class ComplexMain {
    public static void main(String[] args) {
        Complex alpha = new Complex();
        Complex beta = new Complex();
        alpha.re = 3;
        alpha.im = 2;
        beta.re = 1;
        beta.im = 2;
        alpha.add(beta);
        alpha.printComp();
        System.out.println(alpha.abs());
    }
}
