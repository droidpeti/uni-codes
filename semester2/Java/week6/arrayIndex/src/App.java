import java.util.InputMismatchException;
import java.util.Scanner;

public class App {
    public static void main(String[] args) throws Exception {
        try(Scanner scanner = new Scanner(System.in)){
            int[] nums = {10, 20, 30, 40, 50};
            
            System.out.print("Please enter a number from 0 to " + (nums.length-1) + ": ");
            int index = scanner.nextInt();
            if(index < 0 || index > nums.length-1){
                throw new ArrayIndexOutOfBoundsException();
            }
            
            System.out.println(nums[index]);

        }catch(InputMismatchException e){
            System.out.println("Error: Couldn't convert to an integer");
        }
        catch(ArrayIndexOutOfBoundsException e){
            System.out.println("Error: The number was either too small or too big");
        }
    }
}
