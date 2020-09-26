use strict;
use JSON;
use common;
use Data::Dumper;
use Time::localtime;


printf("Using common " . common::getVersion() . "\n\n");

my $link = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=IBM&interval=5min&apikey=demo";
`wget -O data.json \"$link\"`;
my $data;
common::filesysFileToVariable("debug", ".\\data.json", \$data);  

my $jsonDecoded = decode_json($data);
my $hourBefore = DateTime->now();

#now is in UTC, so we need to first correct for PST (+9) and then take one hour (-1), so in total -8
$hourBefore->subtract(minutes => 60*8); #now is in UTC, I'm in UTC+2, so if I add 60 minutes that will be minus one hour UTC)

#just to get any results as it is now almost midnight PST
$hourBefore->subtract(hours => 10);

printf("Hour before: " . $hourBefore->ymd . " " . $hourBefore->hms . "\n");

for my $key (keys $jsonDecoded->{'Time Series (5min)'}) {
    
    my $hour = localtime(time)->hour; 
    
    if ($key =~ /(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/) {
    
        my $year = $1;
        my $month = $2;
        my $day = $3;
        my $hour = $4;
        my $minute= $5;
        my $second = $6;
        
        my $currDateTime = DateTime->new(
            year => $year,
            month => $month,
            day => $day,
            hour => $hour,
            minute => $minute,
            second => $second            
        );        
        
        my $elapse = $currDateTime - $hourBefore;                 
        my $minutesFromQuote =  $elapse->in_units('minutes');                       
        
        #printf("current d/t: " . $currDateTime->ymd . " " . $currDateTime->hms . "difference: " . $minutesFromQuote . "\n");
    
        if ($minutesFromQuote >= 0 && $minutesFromQuote <= 60) {
            printf("$key ($minutesFromQuote) " . $jsonDecoded->{'Time Series (5min)'}->{$key}->{'4. close'});
            printf("\n");
        }
            
    }             
} 






