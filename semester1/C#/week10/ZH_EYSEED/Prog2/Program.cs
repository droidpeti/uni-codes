using System;

namespace Prog2
{
    class Program
    {
        public struct Student
        {
            public string Name;
            public string[] Sports;

            public void ReadStudent()
            {
                System.Console.Write("\nPlease enter student name: ");
                Name = Console.ReadLine();

                int count;
                do
                {
                    System.Console.Write($"How many sports will {Name} participate in? ");
                } while (!Int32.TryParse(Console.ReadLine(), out count) || count < 0);

                Sports = new string[count];
                
                for (int i = 0; i < count; i++)
                {
                    while (true)
                    {
                        System.Console.Write($"  Please input sport #{i + 1}: ");
                        string sport = Console.ReadLine();
                        bool alreadyExists = false;
                        for(int j = 0; j < i; j++)
                        {
                            if(Sports[j].ToLower() == sport.ToLower())
                            {
                                alreadyExists = true;
                                break;
                            }
                        }

                        if (alreadyExists)
                        {
                            System.Console.WriteLine("  You already added this sport! Try again.");
                        }
                        else if (string.IsNullOrWhiteSpace(sport))
                        {
                            System.Console.WriteLine("  Sport name cannot be empty.");
                        }
                        else
                        {
                            Sports[i] = sport;
                            break;
                        }
                    }
                }
            }
        }

        static Student[] InputStudents()
        {
            int n;
            do
            {
                Console.Write("How many students do you want to register? ");
            } while (!int.TryParse(Console.ReadLine(), out n) || n < 1);

            Student[] students = new Student[n];

            for (int i = 0; i < n; i++)
            {
                students[i] = new Student();
                students[i].ReadStudent();
            }

            return students;
        }
        static Student? FindStudentWithThreeSports(Student[] students)
        {
            foreach (var student in students)
            {
                if (student.Sports != null && student.Sports.Length == 3)
                {
                    return student;
                }
            }
            return null;
        }
        static void PrintResult(Student? student)
        {
            if (student.HasValue)
            {
                Console.WriteLine($"Found a student with 3 sports: {student.Value.Name}");
                Console.WriteLine("Sports: " + string.Join(", ", student.Value.Sports));
            }
            else
            {
                Console.WriteLine("No student found who entered exactly 3 sports.");
            }
        }

        static void Main(string[] args)
        {
            Student[] classList = InputStudents();

            Student? result = FindStudentWithThreeSports(classList);

            PrintResult(result);
        }
    }
}
