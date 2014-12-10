use strict;
use warnings;
use 5.010;
use utf8;
use Text::CSV;

my $csv = Text::CSV -> new({binary => 1, sep_char => ';'});

sub fgets {
    my($fh, $limit) = @_;

    my($char, $str);
    for(1..$limit) 
	{
        my $char = getc $fh;
        last unless defined $char;
        $str .= $char;
        last if $char eq "\n";
    }

    return $str;
}

sub configXML
{
	print {$_[0]} "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<kml xmlns=\"http://www.opengis.net/kml/2.2\" xmlns:gx=\"http://www.google.com/kml/ext/2.2\" xmlns:kml=\"http://www.opengis.net/kml/2.2\" xmlns:atom=\"http://www.w3.org/2005/Atom\">
<Document>\n";
}

#sub escreveXML
#{
	#print join("-",@_);
	
#	my $arq = @_[0];
#	my (@registro) = split (/,/,@_[1]);
#	my $count = @_[2];
		
#	print {$_[0]} "\t<name>$registro[$count].kml</name>\n";
	
	
#}

system('cls');

print "\n--> Insira o nome do arquivo (com extensao): ";
my $nome = <>;
chomp $nome;

open my $tabela, "<", $nome or die "\nNao foi possivel abrir o arquivo. $!";

my $linha = fgets($tabela, 500); 
chomp $linha;

$csv -> parse($linha) or die "\nNao foi possivel utilizar o arquivo. $!";
my @header = $csv -> fields();
my @registro;
my $count = 0;

foreach (@header)														#count recebe a posicao da coluna UF
{
	if(@header[$count] eq "UF")
	{
		last;
	}
	else
	{
		$count++;
	}
} 					

my $UF = @header[$count]; 												#flag UF recebe atual

while($linha = fgets($tabela,1000)) 									#enquanto houver registro
{	
	chomp $linha;
	$csv -> parse($linha);
	@registro = $csv -> fields();

	if(!($UF eq @registro[$count])) 									#se flag UF for diferente atual, abre novo arquivo
	{	
		open my $xml, ">", @registro[$count].".kml" or die;
		
		configXML($xml);
		#escreveXML($xml, @registro, $count);
		
		print {$xml} "\t<name>@registro[$count].kml</name>\n\t<Placemark>\n\t\t";
		
		
	}
	else
	{
		open my $xml, ">", @registro[$count].".kml" or die;
		#escreveXML($xml, @registro, $count);
	}
	
	$UF = @registro[$count];
}

close $tabela;
