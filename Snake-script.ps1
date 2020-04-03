#Klasa - Plansza

class Plansza{

    [int] $szerokosc
    [int] $wysokosc
 
    rysujPlansze()
    {   
        for ($x = 0; $x -lt $this.szerokosc; $x++)
        {
            $this.rysujPozKrawedz($x,0)
            $this.rysujPozKrawedz($x,$this.wysokosc - 1)
        }

        for ($y = 1 ; $y -lt $this.wysokosc; $y++)
        {
            $this.rysujPionKrawedz(0,$y)
            $this.rysujPionKrawedz($this.szerokosc - 1,$y)
        }
    }

    rysujPionKrawedz($x, $y)
    {
        [console]::SetCursorPosition($x + 1, $y + 1)
        Write-Host -ForegroundColor White -BackgroundColor DarkMagenta '|' -NoNewline
        $global:tablica[$x, $y] = 1
    }

    rysujPozKrawedz($x, $y)
    {
        [console]::SetCursorPosition($x + 1, $y + 1)
        Write-Host -ForegroundColor White -BackgroundColor DarkMagenta '-' -NoNewline
        $global:tablica[$x, $y] = 1
    
    }
}

#Klasa - Punkty

class Punkty{
    [int] $wynik

    Punkty(){
    $this.wynik = 0
    }

    ustawPunkty($szerokosc){
        $str = "Punkty:" + $this.wynik
        $xPos = [int](($szerokosc - 8) / 2)
        [console]::SetCursorPosition($xPos, 0)

        Write-Host -ForegroundColor White -BackgroundColor DarkMagenta $str
    }
}

#Klasa Jablko 

class Jablko{
    
    rysujJablko($x,$y){
        [console]::SetCursorPosition($x +1, $y + 1)
        Write-Host -foregroundcolor White -backgroundcolor DarkMagenta "O"
        $global:tablica[$x,$y] = 2
    }

    ustawJablko($szerokosc, $wysokosc)
    {
        $losuj = $true
        while($losuj){
            $x = get-random -min 2 -max ($szerokosc - 2)
            $y = get-random -min 2 -max ($wysokosc - 2)

           if($global:tablica[$x, $y] -eq 0){
                $losuj = $false
                $this.rysujJablko($x,$y)
            }            
        }       
    }
}
#Klasa - Waz

enum ruch_weza{
    prawo
    lewo
    gora
    dol
}

class Waz{
      
    [int] $x 
    [int] $y
    [int] $dlugosc
    [System.Collections.Queue]$waz
    [ruch_weza] $ruch

    Waz(){
        $this.waz= New-Object System.Collections.Queue
        $this.dlugosc = 3
        $this.ruch = "prawo"

    }
    ruchWeza(){  
        $segment = $this.x, $this.y
        $this.waz.Enqueue($segment)
        $this.rysujSegment()

        if($this.waz.Count -gt $this.dlugosc){
            $usun = $this.waz.Dequeue()

            $global:tablica[$usun[0], $usun[1]] = 0
            [console]::SetCursorPosition($usun[0] + 1, $usun[1] + 1)
            Write-Host -ForegroundColor White -BackgroundColor DarkMagenta -NoNewline " " 
        }  
    }

    rysujSegment(){
        $global:tablica[$this.x, $this.y] = 3
        [console]::SetCursorPosition($this.x + 1, $this.y + 1)
        Write-Host -ForegroundColor White -BackgroundColor White -NoNewline " "
    }
}

# Klasa - gra 

class Gra {
    
    [Waz] $waz 
    [Jablko] $jablko
    [Punkty] $punkty
    [int] $szerokosc
    [int] $wysokosc
    [bool] $play

    Gra(){

        #Czyszczenie ekranu
        cls

        #UI
        $ui=(get-host).ui
        $rui=$ui.rawui

        #Kursor
        $rui.cursorsize=0 

        #Szerokosc i wysokosc 
        $this.szerokosc = $rui.WindowSize.Width - 2
        $this.wysokosc = $rui.WindowSize.Height - 2

        $global:tablica = New-Object 'int[,]' -ArgumentList ($this.szerokosc, $this.wysokosc) # domyslnie zera

        # 0 - pole_pust
        # 1 - krawedz
        # 2 - jablko
        # 3 - waz

        #Dodanie planszy
        $plansza = New-Object Plansza
        $plansza.szerokosc = $this.szerokosc
        $plansza.wysokosc = $this.wysokosc
        $plansza.rysujPlansze()

        #Ustawienie Punktow

        $this.punkty = New-Object Punkty
        $this.punkty.ustawPunkty($rui.WindowSize.Width - 2)

        #Ustawienie Jablka 
        
        $this.jablko = New-Object Jablko
        $this.jablko.ustawJablko($this.szerokosc,$this.wysokosc)

        #Waz

        $this.waz = New-Object Waz
        $this.waz.x = [int] ($this.szerokosc / 2)
        $this.waz.y = [int] ($this.wysokosc / 2)

        $this.waz.ruchWeza()

        $this.play = $true

    }

    sprawdzZjedzenieJablka($x, $y){
    if($global:tablica[$x,$y] -eq 2){
        #Zwiekszenie dlugosci węza
        $this.waz.dlugosc++

        #Wylosowanie innego miejsca na jablko 
        $this.jablko.ustawJablko($this.szerokosc,$this.wysokosc)

        #Zwiekszenie punktów
        $this.punkty.wynik++
        $this.punkty.ustawPunkty($this.szerokosc)
        }
    }

    sprawdzSciane($x, $y)
    {
        if ($global:tablica[$x, $y] -eq 1)
        {
            cls
            [console]::SetCursorPosition(($this.szerokosc / 2)  - 3 , $this.wysokosc / 2)
            write-host -foregroundcolor White "GAME OVER"

            [console]::SetCursorPosition(($this.szerokosc / 2) - 7 , $this.wysokosc / 2 + 2)
            write-host -foregroundcolor White "Zdobyte punkty:" $this.punkty.wynik

            [console]::SetCursorPosition(($this.szerokosc / 2) - 10 , $this.wysokosc / 2 + 6)
            write-host -foregroundcolor White "Press ANY to play again"
            $this.play = $false
            $script:nowaGra = $true
        }
    }

    sprawdzZderzenieWeza($x, $y)
{
    if ($global:tablica[$x, $y] -eq 3)
    {
        cls
        [console]::SetCursorPosition(($this.szerokosc / 2)  - 3 , $this.wysokosc / 2)
        write-host -foregroundcolor White "GAME OVER"

        [console]::SetCursorPosition(($this.szerokosc / 2) - 7 , $this.wysokosc / 2 + 2)
         write-host -foregroundcolor White "Zdobyte punkty:" $this.punkty.wynik

        [console]::SetCursorPosition(($this.szerokosc / 2) - 10 , $this.wysokosc / 2 + 6)
        write-host -foregroundcolor White "Press ANY to play again"
        $this.play = $false
        $script:nowaGra = $true
    }
}

    graj(){
    $ui=(get-host).ui
    $rui=$ui.rawui

        while($this.play){
            if ($rui.KeyAvailable)
            {
                $keyopt = [System.Management.Automation.Host.ReadKeyOptions]”NoEcho,IncludeKeyDown,IncludeKeyUp”
                $key = $rui.ReadKey($keyopt)
               
                if ($key.keydown)
                {
                    #Strzalka - w lewo 
                    if ($key.virtualkeycode -eq 37)
                    {
                        if($this.waz.ruch -ne "prawo"){
                            $this.waz.ruch = "lewo"
                        }              
                    }   
                    # Strzałka - do góry 
                    if ($key.virtualkeycode -eq 38)
                    {
                        if($this.waz.ruch -ne "dol"){
                            $this.waz.ruch = "gora"
                        }                   
         
                    } 
                    # Strzałka - w prawo
                    if ($key.virtualkeycode -eq 39)
                    {
                        if($this.waz.ruch -ne "lewo"){
                            $this.waz.ruch = "prawo"
                        }   
                
                    }
                    # Strzałka - do dolu
                    if ($key.virtualkeycode -eq 40)
                    {
                         if($this.waz.ruch -ne "gora"){
                            $this.waz.ruch = "dol"
                        }   
                    }
                }       
            }
            if($this.waz.ruch -eq "lewo"){
                $this.waz.x--
            }
            if($this.waz.ruch -eq "prawo"){
                $this.waz.x++
            }
            if($this.waz.ruch -eq "gora"){
                $this.waz.y-- 
            }
            if($this.waz.ruch -eq "dol"){
                $this.waz.y++
            }

            $this.sprawdzZjedzenieJablka($this.waz.x,$this.waz.y)
            $this.sprawdzSciane($this.waz.x,$this.waz.y)
            $this.sprawdzZderzenieWeza($this.waz.x,$this.waz.y)
            $this.waz.ruchWeza()

            start-sleep -mil 100
        }

    }
}


# --------------------------------------------
#-------------------Main---------------------- 
# --------------------------------------------

$script:nowaGra = $false

#UI
$ui=(get-host).ui
$rui=$ui.rawui

$gra = New-Object Gra
$gra.graj()

while($true){
    if($script:nowaGra -eq $true){
        #Czekanie na klawisz ENTER
        if ($rui.KeyAvailable)
            {
                $key = $rui.ReadKey()
                Write-Host $key
                if ($key.keydown)
                {
                    $gra = New-Object Gra
                    $gra.graj()
                    
                }
            }
    }
}
