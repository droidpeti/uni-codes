package semester2.Java.week2;

class Point{
    private double x;
    private double y;

    public Point(double xIn, double yIn){
        x = xIn;
        y = yIn;
    }

    public void move(double dx, double dy){
        x += dx;
        y += dy;
    }

    public void mirror(Point p){
        mirror(p.x, p.y);
    }

    public void mirror(double cx, double cy){
        move(2*(cx - x), 2*(cy - y));
    }

    public double distance(Point p){
        return Math.sqrt(Math.pow(p.x - x, 2) + Math.pow(p.y - y, 2));
    }

    public void printPoint(){
        System.out.println("x: " + x + " y: " + y);
    }
}

public class PointMain {
    public static void main(String[] args) {
        Point point1 = new Point(0, 0);
        point1.printPoint();
        point1.move(3, 3);
        point1.printPoint();
        point1.mirror(0, 0);
        point1.printPoint();

        Point point2 = new Point(2,5);
        System.out.println("Distance between the two points: ");
        point1.printPoint();
        point2.printPoint();
        System.out.println(point1.distance(point2));
    }
}
