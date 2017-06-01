Camau Hyfforddi
---------------

Mae'r camau canlynol yn estyn corpws lleferydd a lecsicon ynganu Cymraeg o'r 
Porth Technolegau Iaith ac yn ei pharatoi ar gyfer hyfforddi modelau acwstig 
o fewn Kaldi: 

$ ./local/init.sh
$ ./local/getdata.sh
$ ./local/getlexicon.sh


Mae angen corpws testun ar gyfer hyfforddi model iaith y parth ar gyfer defnyddio'r 
adnabod lleferydd. Mae corpws o gwestiynau prototeip cynorthwyydd digidol Macsen 
gyda ffeiliau sail ar gyfer profi ar gael. Defnyddiwch y gorchmynyn canlynol i'w estyn:

$ ./local/getlanguagecorpus.sh -e Macsen 

Defnyddiwch y gorchmynion canlynol i baratoi popeth ar gyfer y cam olaf: 

$ ./local/prepare_audio.sh
$ ./local/prepare_dict.sh

Defnyddiwch y gorchymyn hwn er mwyn creu modelau acwstig ac iaith:

$ ./run.sh


