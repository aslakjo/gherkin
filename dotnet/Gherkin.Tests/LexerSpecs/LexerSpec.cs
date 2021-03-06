using System;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using Gherkin.Lexer;
using Xunit;

namespace Gherkin.Tests.LexerSpecs
{
    public class LexerSpec
    {
        protected LexerDecl a_lexer()
        {
            return new LexerDecl();
        }

        protected class LexerDecl
        {
            private string language = "en";
            private bool useColumns = false;
            internal LexerDecl with_language(string language)
            {
                this.language = language;
                return this;
            }

            internal LexingResult lexing_input(string input)
            {
                var listener = new SExpListener(useColumns);
                var lexer = Gherkin.Lexers.Create(language, listener);

                try
                {
                    //lexer.Scan(new StringReader(input));
                    lexer.Scan(new StringReader(input.Replace("\r", "")));
                    return new LexingResult(listener.Value);
                }
                catch (Exception e)
                {
                    return new LexingResult(e);
                }
            }

            internal LexingResult scan_file(string fileName)
            {
                using (var fileStream = GetFixtureFileContent(fileName))
                {
                    var encoding = DetermineEncoding(fileStream, Encoding.UTF8);
                    using (var stream = new StreamReader(fileStream, encoding))
                    {
                        var content = stream.ReadToEnd();
                        return lexing_input(content);
                    }
                }
            }

            private Stream GetFixtureFileContent(string fileName)
            {
                var currentAssembly = Assembly.GetExecutingAssembly();
                return currentAssembly.GetManifestResourceStream(string.Format("Gherkin.Tests.fixtures.{0}", fileName));
            }

            protected Encoding DetermineEncoding(Stream stream, Encoding defaultEncoding)
            {
                if (!stream.CanSeek)
                    return defaultEncoding;

                var encodingsToTest = new[] { Encoding.BigEndianUnicode, Encoding.Unicode, Encoding.UTF32, Encoding.UTF8 };

                foreach (var enc in encodingsToTest)
                {
                    var preamble = enc.GetPreamble();
                    var start = new byte[preamble.Length];
                    var read = stream.Read(start, 0, preamble.Length);
                    stream.Position = 0;

                    if (read == preamble.Length && start.SequenceEqual(preamble))
                        return enc;
                }
                return defaultEncoding;
            }

            internal LexerDecl using_column_positions()
            {
                useColumns = true;
                return this;
            }
        }

        protected class LexingResult
        {
            private readonly SExp result;
            private readonly Exception exception;
            public LexingResult(SExp result)
            {
                this.result = result;
            }

            public LexingResult(Exception exception)
            {
                this.exception = exception;
            }

            public void should_result_in(string expected)
            {
                Assert.True(exception == null, string.Format("Lexing failed with message {0}", exception != null ? exception.Message : ""));
                var expectedExpression = new SExpReader(new StringReader(expected)).Read();
                Assert.Equal(expectedExpression, result);
            }

            public void should_fail_with_message(string errorMessage)
            {
                Assert.True(exception != null, "Lexing not failed");
                Assert.Equal(errorMessage, exception.Message);
            }

            public void should_fail_with(Func<Exception, bool> testException)
            {
                Assert.True(exception != null, "Lexing not failed");
                Assert.True(testException(exception));
            }
        }
    }
}