import java.io.FileReader;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.StringReader;
import java.util.Map;

import java_cup.runtime.*;

class SC {
  public static void main(String[] argv) {

    if(argv.length != 1){
      System.err.printf("USAGE:\n  %s\n",
"java -cp bin:lib/java-cup-11b-runtime.jar SC input_file"
      );
      System.exit(1);
    }

    String inputFile = null;

    inputFile = argv[0];

    if(inputFile == null){
      System.err.println("Specify input file as the last argument");
      System.exit(1);
    }

    try {
      Lexer lexer   = new Lexer(new FileReader(inputFile));
      Parser parser = new Parser(lexer);

      /* if(showLexing){
        lexer.debug(true);
      } */

      java_cup.runtime.Symbol symbol = null;

      try {
        Symbol result = parser.parse();
        System.out.println("parsing successful");
      } catch (Exception e) {

      }

      //System.out.println();
    } catch (FileNotFoundException e) {
      System.err.printf("Could not find file <%s>\n", argv[0]);
      System.exit(1);

    } catch (/* Yuk, but CUP gives us no choice */ Exception e) {
      e.printStackTrace();
    }
  }
}
