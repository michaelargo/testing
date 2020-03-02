using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Text.RegularExpressions;

namespace BP_Technical_Test_4
{
    class Program
    {
        static void Main(string[] args)
        {
            
            string StartWord;
            string EndWord;
            string ResultFile;
            string DictionaryPath;
            string ResultFilePath;
                        
            DictionaryPath = args[0];
            StartWord = args[1];
            EndWord = args[2];
            ResultFile = args[3];
            ResultFilePath = "c:\\tools\\" + ResultFile;
            string newLine = Environment.NewLine;


            var Dict = new System.Collections.Generic.List<string>();
            var Results = new System.Collections.Generic.List<string>();

                       
            if (args == null)
            {
                Console.WriteLine("Argument List Invalid!");
            }
            else
            {
               
                // filepath c:\\tools\\words-english.txt
                Console.Write("args length is ");
                Console.WriteLine(args.Length);
                for (int i = 0; i < args.Length; i++)
                {
                    string argument = args[i];
                    Console.Write("args index ");
                    Console.Write(i); 
                    Console.Write(" is [");
                    Console.Write(argument);
                    Console.WriteLine("]");
                }
            }

            Dict = getFileToList(DictionaryPath);
            Results = ReturnResults(Dict, StartWord, EndWord);
            WriteResults(Results, ResultFilePath);


            Console.WriteLine("Dictionary Path:" + DictionaryPath);
            Console.WriteLine("Start Word:" + StartWord);
            Console.WriteLine("End Word:" + EndWord);
            Console.WriteLine("Result File:" + ResultFile);
            Console.WriteLine("Result File Path:" + ResultFilePath);
            Console.WriteLine("Count of Dictionary File:" + Dict.Count.ToString());
            Console.ReadLine();

            
        }

        public static List<string> getFileToList(string DictionaryPath)
        {

            var Dict = new System.Collections.Generic.List<string>();

            try
            {
                using (StreamReader sr = new StreamReader(DictionaryPath))
                {
                    string line;

                    while ((line = sr.ReadLine()) != null)
                    {
                        Dict.Add(line);

                    }
                }
            }


            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }

            return Dict;
        }

        public static List<string> ReturnResults(List<string> MyList, string firstWord, string lastWord)
        {

            var regex = new Regex("^[^\\s]{4}$");
            var RTempList = new System.Collections.Generic.List<string>();
            var STempList = new System.Collections.Generic.List<string>();

            int firstIndex;
            int lastIndex;
            int count = 0;

            firstIndex = MyList.FindIndex(x => x.StartsWith(firstWord));
            lastIndex = MyList.FindIndex(x => x.StartsWith(lastWord));
            count = (lastIndex + 1) - (firstIndex - 1);

            RTempList = MyList.GetRange(firstIndex, count);

            Console.WriteLine("Count of intermediate list: " + RTempList.Count.ToString());

            STempList = RTempList.Where(f => regex.IsMatch(f)).ToList();

            Console.WriteLine("Count of Regex'd list: " + STempList.Count.ToString());
            //Console.WriteLine("Contents of Regex'd list.");
            
            /*
            foreach (string s in STempList) 
            {

            Console.WriteLine(s);

            }
            */

            return STempList;
        }

        public static void WriteResults(List<string> STempList, string ResultFilePath)
        {

            using (StreamWriter tw = File.CreateText(ResultFilePath))
            {
                //File.Open(ResultFilePath, FileMode.Open, FileAccess.Write;)
                
                foreach (string s in STempList)
                {

                    tw.WriteLine(s);
                    
                    //Console.WriteLine(s);

                }
                Console.WriteLine("Done!");
                tw.Close();

                //System.IO.File.WriteAllLines(ResultFilePath, STempList);
            }

                  
            
                                 
        }

    }

    
}
