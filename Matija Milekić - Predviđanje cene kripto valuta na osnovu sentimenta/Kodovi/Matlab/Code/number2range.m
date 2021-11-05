function [ rangeLetter ] = number2range( numberOfColums )

switch numberOfColums
    case 1
        rangeLetter='A';
    case 2
        rangeLetter='B';
    case 3
        rangeLetter='C';
    case 4
        rangeLetter='D';
    case 5
        rangeLetter='E';
    case 6
        rangeLetter='F';
    case 7
        rangeLetter='G';
    case 8
        rangeLetter='H';
    case 9
        rangeLetter='I';
    case 10
        rangeLetter='J';
    case 11
        rangeLetter='K';
    case 12
        rangeLetter='L';
    case 13
        rangeLetter='M';
    case 14
        rangeLetter='N';
    case 15
        rangeLetter='O';
    case 16
        rangeLetter='P';
    case 17
        rangeLetter='Q';
    case 18
        rangeLetter='R';
    case 19
        rangeLetter='S';
    case 20
        rangeLetter='T';
    case 21
        rangeLetter='U';
    case 22
        rangeLetter='V';
    case 23
        rangeLetter='W';
    case 24
        rangeLetter='X';
    case 25
        rangeLetter='Y';
    case 26
        rangeLetter='Z';
    case 27
        rangeLetter='AA';
    case 28
        rangeLetter='AB';
    case 29
        rangeLetter='AC';
    case 30
        rangeLetter='AD';
    case 31
        rangeLetter='AE';
    case 32
        rangeLetter='AF';
    case 33
        rangeLetter='AG';
    case 34
        rangeLetter='AH';
    case 35
        rangeLetter='AI';
    case 36
        rangeLetter='AJ';
    case 37
        rangeLetter='AK';
    case 38
        rangeLetter='AL';
    case 39
        rangeLetter='AM';
    case 40
        rangeLetter='AN';
    case 41
        rangeLetter='AO';
    case 42
        rangeLetter='AP';
    case 43
        rangeLetter='AQ';
    case 44
        rangeLetter='AR';
    case 45
        rangeLetter='AS';
    case 46
        rangeLetter='AT';
    case 47
        rangeLetter='AU';
    case 48
        rangeLetter='AV';
    case 49
        rangeLetter='AW';
    case 50
        rangeLetter='AX';
    case 51
        rangeLetter='AY';
    case 52
        rangeLetter='AZ';
    case 53
        rangeLetter='BA';
    case 54
        rangeLetter='BB';
    case 55
        rangeLetter='BC';
    case 56
        rangeLetter='BD';
    case 57
        rangeLetter='BE';
    case 58
        rangeLetter='BF';
    case 59
        rangeLetter='BG';
    case 60
        rangeLetter='BH';
    case 61
        rangeLetter='BI';
    case 62
        rangeLetter='BJ';
    case 63
        rangeLetter='BK';
    case 64
        rangeLetter='BL';
    case 65
        rangeLetter='BM';
    case 66
        rangeLetter='BN';
    case 67
        rangeLetter='BO';
    case 68
        rangeLetter='BP';
    case 69
        rangeLetter='BQ';
    case 70
        rangeLetter='BR';
    case 71
        rangeLetter='BS';
    case 72
        rangeLetter='BT';
    case 73
        rangeLetter='BU';
    case 74
        rangeLetter='BV';
    case 75
        rangeLetter='BW';
    case 76
        rangeLetter='BX';
    case 77
        rangeLetter='BY';
    case 78
        rangeLetter='BZ';
    otherwise
        rangeLetter=NaN;
        disp('GRESKA u metodi @number2range. Range van definisanih granica!')
end

end

       