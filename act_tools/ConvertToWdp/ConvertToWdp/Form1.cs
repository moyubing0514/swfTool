using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Text;
using System.Windows.Forms;
using System.Windows.Media.Imaging;
using System.Text.RegularExpressions;
namespace ConvertToWmp
{
    public partial class Form1 : Form
    {
        private String _extensionName = "wdp";
        public Form1()
        {
            InitializeComponent();
        }

        private void btnConvert_Click(object sender, EventArgs e)
        {
            Match m = Regex.Match(qualityBox.Text, @"^(-?\d+)(\.\d+)?$");
            if (!m.Success || float.Parse(qualityBox.Text) > 1 || float.Parse(qualityBox.Text) < 0)
            {
                MessageBox.Show("输入错误 请输入0.0到1.0之间的数字");
                qualityBox.Focus();
            }
            else
            {
                _extensionName = extensionBox.Text;
                float quality = float.Parse(qualityBox.Text);
                // Prompt to open the file
                if (selectFolder.ShowDialog() == DialogResult.OK)
                {
                    // Prompt to save the file

                    // Call the method that does all the work
                    //  FileToWmp(, saveWdp.FileName);
                    DirectoryInfo dInfo = new DirectoryInfo(selectFolder.SelectedPath);
                   // Directory.CreateDirectory(dInfo.FullName + EXPORT_FOLDER);
                    foreach (FileInfo file in dInfo.GetFiles())
                    {
                        Console.WriteLine(file.FullName);
                        String fExtension = file.Extension;
                        if (fExtension == ".jpg" || fExtension == ".jpeg" || fExtension == ".png")
                        {
                            String outName = dInfo.FullName  + "\\" + file.Name.Split('.')[0] + "." + _extensionName;
                            FileToWmp(file.FullName, outName, quality);
                        }
                    }

                }
            }
        }

        public static void FileToWmp(string inFile, string outFile, float f)
        {
            // Container for bitmap frames
            BitmapDecoder bdFile = null;
            // Read the source file into a FileStream object
            FileStream readFile = File.OpenRead(inFile);
            // Set the BitmapDecoder object from the source file
            bdFile = BitmapDecoder.Create(readFile, BitmapCreateOptions.PreservePixelFormat, BitmapCacheOption.None);
            // Prepare the output file
            FileStream writeFile = File.OpenWrite(outFile);
            // All the magic done by WmpBitmapEncoder
            WmpBitmapEncoder wbeFile = new WmpBitmapEncoder();
            // Set the quality level to... pretty good
            wbeFile.ImageQualityLevel = f;
            // Add the bitmap frame to the encoder object
            wbeFile.Frames.Add(bdFile.Frames[0]);
            // Write the output file
            wbeFile.Save(writeFile);
            writeFile.Close();
            readFile.Close();
        }
    }
}