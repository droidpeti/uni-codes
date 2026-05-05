using System;

namespace MyApp;

public class Subject
{
    public string name;
    public List<Exam> exams;

    public bool HasPost()
    {
        foreach (Exam exam in exams)
        {
            if(exam.type == ExamType.Post)
            {
                return true;
            }
        }
        return false;
    }
}

public class Exam
{
    public ExamType type;
    public string date;
    public List<string> rooms;
}

public enum ExamType
{
    Regular,
    Post
}
public class Program
{
    static string featured = "";
    static List<Subject> subjects = new List<Subject>();
    static void Main(string[] args)
    {
        string filename = "input.txt";
        Read(filename);
        Console.WriteLine(subjects[1].exams[0].date);
        Console.WriteLine(featured);
    }

    static void Read(string filename)
    {
        StreamReader sr = new StreamReader(filename);
        int subjectCount = int.Parse(sr.ReadLine());
        for(int i = 0; i < subjectCount; i++)
        {
            Subject subject = new Subject();
            string[] row = sr.ReadLine().Split(" ");
            subject.name = row[0];
            int examCount = int.Parse(row[1]);
            subject.exams = new List<Exam>();
            for(int j = 0; j < examCount; j++)
            {
                Exam exam = new Exam();
                row = sr.ReadLine().Split(new char[]{' ', '\t'});

                // N-U: Examtype ->
                switch (row[0])
                {
                    case "N":
                        exam.type = ExamType.Regular;
                        break;
                    case "U":
                        exam.type = ExamType.Post;
                        break;
                    default:
                        break;
                }
                exam.date = row[1];
                exam.rooms = row.Skip(2).ToList();
                subject.exams.Add(exam);
            }

            subjects.Add(subject);
        }
        featured = sr.ReadLine();
        sr.Close();
    }
}
