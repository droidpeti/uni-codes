import java.util.InputMismatchException;
import java.util.Scanner;

public class App {
    public static void main(String[] args) {
        try (Scanner scanner = new Scanner(System.in)) {
            int num1, num2;

            System.out.print("Please enter an integer: ");
            num1 = scanner.nextInt();
            
            System.out.print("Please enter a second integer: ");
            num2 = scanner.nextInt();

            if (num2 == 0) {
                System.out.println("Error: Cannot divide by zero.");
            } else {
                System.out.println(num1 + " / " + num2 + " = " + ((float)num1 / (float)num2));
            }

        } catch (InputMismatchException e) {
            System.out.println("Error: Not a valid integer.");
        } finally {
            System.out.println("Finished");
        }
    }
}