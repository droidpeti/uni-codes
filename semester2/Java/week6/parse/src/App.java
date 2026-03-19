import java.util.Scanner;

public class App {
    public static void main(String[] args) throws Exception {
        try(Scanner scanner = new Scanner(System.in)){
            System.out.print("Please enter an integer: ");
            int num = Integer.parseInt(scanner.nextLine());
            System.out.println(num + " * " + "2" + " = " + (num*2));
        } catch (NumberFormatException e) {
            System.out.println("Error: couldn't convert to an Integer");
        }
    }
}
