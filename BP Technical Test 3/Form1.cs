using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace BP_Technical_Test_3
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            string Requested_Language = "English (United States)";
            string ukin = "English (United Kingdom)";
            string uk = "en-GB";
            string usin = "English (United States)";
            string us = "en-US";
            string setlang = "";
            
            var ukculture = System.Globalization.CultureInfo.GetCultureInfo(uk);
            var usculture = System.Globalization.CultureInfo.GetCultureInfo(us);
            var uslanguage = InputLanguage.FromCulture(usculture);
            var uklanguage = InputLanguage.FromCulture(ukculture);

            InputLanguage original = InputLanguage.CurrentInputLanguage;

            if (Requested_Language == ukin)
            {

                setlang = uk;

                if (original.Culture.ToString() != setlang)
                {

                    InputLanguage.CurrentInputLanguage = uklanguage;
                    Application.Exit();
                }

            }

            if (Requested_Language == usin)
            {

                setlang = us;

                if (original.Culture.ToString() != setlang)
                {

                    InputLanguage.CurrentInputLanguage = uslanguage;
                    Application.Exit();
                }

            }


            Application.Exit();
            //MessageBox.Show(original.Culture.ToString());

            
        }
    }
}
