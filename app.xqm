xquery version "3.1";

(:~ This is the default application library module of the voci_inferno app.
 :
 : @author Elvira Mercatanti
 : @version 1.0.0
 : @see https://exist-db.org/
 :)

(: Module for app-specific template functions :)
module namespace app="http://exist-db.org/apps/voci_inferno/templates";
import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace lib="http://exist-db.org/xquery/html-templating/lib";
import module namespace config="http://exist-db.org/apps/voci_inferno/config" at "config.xqm";


(: TEI IMPORTATO PER LA RAPPRESENTAZIONE DEGLI ELEMENTI XML :)
declare namespace functx = "http://www.functx.com";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace json = "http://www.json.org";
declare option exist:serialize "method=xhtml media-type=text/html";




(: ---- titolo VOCI DALL'INFERNO in index.html --- :)
declare function app:titolo($node as node(), $model as map (*)){
    
    <div id="title_container">
        <h1 id="titolo_home_page">Voci dall'Inferno</h1>
        <h2 id="sottotitolo">e il Dante dei sommersi e dei salvati</h2>
    </div>
};


declare function local:contaTestimoniCollezione($nome_collezione){
    let $n_testimoni:=
        for $xml in collection($nome_collezione)
        let $find_testimone := $xml//tei:person[@role="testimone"]
        let $nome_testimone := $find_testimone/tei:persName/tei:forename
        let $cognome_testimone :=$find_testimone/tei:persName/tei:surname[1]
        let $testimone :=concat($cognome_testimone," ",$nome_testimone)
        
        order by $testimone (: ordino i testimoni in ordine alfabetico per cognome :)
        return $testimone
    
    let $conta_archivio:=count(distinct-values($n_testimoni))
    return $conta_archivio
        
};

(: -----funzione che conta il numero di testimoni e testimonianze dell'archivio Voci dall'Inferno -----:)
declare function app:contaTestimonianzeArchivio($node as node(), $model as map(*)){
    
    (: calcolo deportati e categorie deportati :)
    let $num_archivio:=local:contaTestimoniCollezione("/db/apps/voci_inferno/xml")-1
    
    let $num_deportati:=local:contaTestimoniCollezione("/db/apps/voci_inferno/xml/Deportati")
    let $num_deportati_ebrei:=local:contaTestimoniCollezione("/db/apps/voci_inferno/xml/Deportati/Ebrei")
    let $num_deportati_IMI:=local:contaTestimoniCollezione("/db/apps/voci_inferno/xml/Deportati/I.M.I")
    
    (: calcolo NON deportati e categorie di NON deportati :)
    let $num_non_deportati:=local:contaTestimoniCollezione("/db/apps/voci_inferno/xml/NonDeportati")
    let $num_non_deportati_partigiani_ebrei:=local:contaTestimoniCollezione("/db/apps/voci_inferno/xml/NonDeportati/PartigianiEbrei")
   
    let $xmlCollection:=collection("/db/apps/voci_inferno/xml")
     
    (: conto quante sono le testimonianze totali:)
    let $titoli := 
        for $xml in $xmlCollection/*
        let $find_testimone := $xml//tei:person[@role="testimone"]
        (:  :let $nome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:forename)
        let $cognome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:surname[1])
        
        where $cognome_testimone = $testimone_split[1] and $nome_testimone = $testimone_split[last()]:)
        for $titolo in $xml//tei:title[@xml:id="titolotestimonianza"]
        return fn:normalize-space(string($titolo))
        
    let $num_testimonianze :=count($titoli)  
    
    return 
        <div>
            
            <head>
                  <script src="http://code.jquery.com/jquery-latest.min.js"></script>
                  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.2/dist/chart.umd.js"></script>
                  <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2"></script>
                  
                         
                    <script src="https://code.highcharts.com/highcharts.js"></script>
                    <script src="https://code.highcharts.com/modules/treemap.js"></script>
                    <script src="https://code.highcharts.com/modules/treegraph.js"></script>
                    <script src="https://code.highcharts.com/modules/exporting.js"></script>
                    <script src="https://code.highcharts.com/modules/accessibility.js"></script>
                    <script src="https://code.highcharts.com/modules/timeline.js"></script>
            </head>
            
            
            
            
            <div id="archivio">
                <p style="margin-top:30px;">L'archivio del progetto <em>Voci dall'Inferno</em> è composto da <b>{$num_testimonianze} testimonianze</b> appartenenti a <b>{$num_archivio} testimoni</b>, suddivisi come segue:</p>
                <ul style="list-style:none; margin-top:20px;">
                    <li> <b>{$num_deportati}</b> testimoni <b>deportati</b> nei Lager </li>
                    <li> <b>{$num_non_deportati} </b> testimoni <b>non deportati</b> </li>
                </ul>
                <br/>
                 <p>Il corpus è suddiviso nelle seguenti categorie: <b>{$num_deportati_ebrei}</b> deportati ebrei, <b>{$num_deportati_IMI}</b> internati militari italiani e <b>{$num_non_deportati_partigiani_ebrei}</b> partigiano ebreo.</p>
            </div>
            
          
            <figure class="highcharts-figure1">
                <div id="container10">
                        <script>
                            Highcharts.chart('container10', {{
                                chart: {{
                                    spacingBottom: 30,
                                    marginRight: 120,
                                    height: 300,
                                    inverted:true
                                }},
                                
                                title: {{
                                    text: "Le Voci del corpus"
                                }},
                                series: [
                                    {{
                                        type: 'treegraph',
                                        keys: ['parent', 'id', 'level'],
                                        clip: false,
                                        data: [
                                            [undefined, 'Testimoni'],
                                            ['Testimoni', 'Deportati'],
                                            ['Testimoni', 'Non deportati'],
                                            ['Deportati', 'Ebrei'],
                                            ['Deportati', 'Internati militari italiani'],
                                            ['Non deportati', 'Partigiani ebrei'],
                                        ],
                                        marker: {{
                                            symbol: 'circle',
                                            radius: 6,
                                            fillColor: '#ffffff',
                                            lineWidth: 3
                                        }},
                                        dataLabels: {{
                                            align: 'left',
                                            pointFormat: '{{point.id}}',
                                            style: {{
                                                color: '#000000',
                                                textOutline: '3px #ffffff',
                                                whiteSpace: 'nowrap'
                                            }},
                                            x: 24,
                                            crop: false,
                                            overflow: 'none'
                                        }}
                                    }}
                                ],
                                nodeWidth: 50
                            }});
                        </script>
                </div>
            </figure>    
          
            
        </div>
        
    
};




(: ---- Funzione che crea l'elenco dei testimoni in base alla collezione ---- :)
declare function app:ElencoTestimoniPerCollezione($node as node(), $model as map(*)){
    
    let $nome_collezione :=request:get-parameter("collezione","")
    
    
    let $collezione:=
        if ($nome_collezione="deportati") then
            let $path:="/db/apps/voci_inferno/xml/Deportati"
            return $path
        else 
            let $path:="/db/apps/voci_inferno/xml/NonDeportati"
            return $path
            
    let $testimoni:=
        for $xml in collection($collezione)
        let $find_testimone := $xml//tei:person[@role="testimone"]
        let $nome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:forename)
        let $cognome_testimone:=fn:normalize-space(string-join($find_testimone/tei:persName/tei:surname, " "))
        let $testimone :=concat($cognome_testimone," ",$nome_testimone)

        
        order by $testimone (: ordino i testimoni in ordine alfabetico per cognome :)
        return $testimone

    
    for $testimone in distinct-values($testimoni)
    return
        <div class="elenco_testimoni"> 
            <section class="testimone">
                <p> 
                    <a class="nome_testimone" onclick='mostra_testimonianze("{$testimone}")'>{($testimone)}</a> 
                </p>
                
            </section>
        </div>
        
};



(: ------- funzione che crea l'elenco dei titoli delle testimonianze -----:)
declare function app:ListaTestimonianzeDelTestimone($node as node(), $model as map(*)){
    
    let $testimone :=request:get-parameter("testimone","")
    let $testimone_split :=tokenize($testimone,"\s")
    let $nome_testimone := concat($testimone_split[last()]," ",$testimone_split[1])
    

    (: restituisco l'elenco delle testimonianze del testimone cliccato e il numero:)
    let $xmlCollection:=collection("/db/apps/voci_inferno/xml")
    let $titoli := 
        for $xml in $xmlCollection/*
        let $find_testimone := $xml//tei:person[@role="testimone"]
        let $nome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:forename)
        let $cognome_testimone:=fn:normalize-space($find_testimone/tei:persName/tei:surname[1])
        
        
        where $cognome_testimone = $testimone_split[1] and $nome_testimone = $testimone_split[last()]
        for $titolo in $xml//tei:title[@xml:id="titolotestimonianza"]
        return (fn:normalize-space(string($titolo)))
        
    let $conta :=count($titoli)   
    
    
    (: estrazione informazioni anagrafiche del testimone :)
    let $info_testimone:=
        for $xml in $xmlCollection/*
        let $find_testimone := $xml//tei:person[@role="testimone"]
        let $nome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:forename)
        let $cognome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:surname[1])
        let $nascita:=concat($find_testimone//tei:birth/tei:date," - ",$find_testimone/tei:birth/tei:placeName/tei:settlement[@type="municipality" or @type="island" or @type="town" or @type="city" or @type="città"], ", ", $find_testimone//tei:birth/tei:placeName/tei:country)
        let $morte:=concat($find_testimone//tei:death/tei:date," - ",$find_testimone/tei:death/tei:placeName/tei:settlement[@type="municipality" or @type="island" or @type="town" or @type="city" or @type="città"], ", ", $find_testimone//tei:death/tei:placeName/tei:country)
       
        where $cognome_testimone = $testimone_split[1] and $nome_testimone = $testimone_split[2]
        
        return ($nascita, $morte) 
        
    let $bio_testimone := 
        for $xml in $xmlCollection/*
        let $find_testimone := $xml//tei:person[@role="testimone"]
        let $nome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:forename)
        let $cognome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:surname[1])
        let $bio := fn:normalize-space($find_testimone//tei:note[1])
        where $cognome_testimone = $testimone_split[1] and $nome_testimone = $testimone_split[last()]
        return $bio
        

    return 
        <div class="cat">
            <h2>{($nome_testimone)}</h2>
           <p style="margin:10%; text-align:center;"><em>
                <!--  {  for $i in distinct-values($bio_testimone)
                    return <div id="bio_testimone">{$i}</div>} -->
                    <!--compare una sola bio anche se essendoci più file ne abbiamo più di una-->
                    <div id="bio_testimone">{$bio_testimone[1]}</div>
                    </em>
            </p> 
     
            
            <div id="lista_testimonianze">
        
                <p>Numero di testimonianze disponibili: <b>{($conta)}</b></p>
                <ul>
                    {
                        for $titolotestimonianza in $titoli 
                        
                        return 
                            <li class="testimonianza" onclick='consulta_testimonianza("{$titolotestimonianza}")'>
                                {($titolotestimonianza)}
                            </li>
                    }

                </ul>
            </div>
        </div>
};





(: funzione per aggiungere immagine e link alla fonte quando si clicca su un testimone :)
declare function app:immagine_wikipedia($node as node(), $model as map(*)){
    
    let $testimone :=request:get-parameter("testimone","")
    let $testimone_split :=tokenize($testimone,"\s")
    let $nome_testimone := concat($testimone_split[last()]," ",$testimone_split[1])
    
    let $xmlCollection:=collection("/db/apps/voci_inferno/xml")
    let $source := 
        for $xml in $xmlCollection/*
        let $find_testimone := $xml//tei:person[@role="testimone"]
        let $nome_testimone := $find_testimone/tei:persName/tei:forename
        let $cognome_testimone:=fn:normalize-space($find_testimone/tei:persName/tei:surname[1])
        
        where $cognome_testimone = $testimone_split[1] and $nome_testimone = $testimone_split[last()]
        let $fonte := $xml//tei:person[@role="testimone"]/@source
        return $fonte
    

    let $nome_per_img:=concat($testimone_split[last()],"_",$testimone_split[1]) (: preparo la stringa per il nome dell'immagine. Ed esempio: Edith_Bruck :)
    let $immagine:=concat("resources/images/",$nome_per_img,".jpg")   (: Edith_Bruck :)
    
    return 
        <div class="immagine_e_fonte">
            <img id="img_testimone" src="{$immagine}" alt="Immagine del testimone"/>
            <button><a id="linkFonte" target="blank" href="{$source[1]}">Approfondimento esterno</a></button>
            
            <!--<div id="tabella_organizzazioni" class="section_tabella">
            <h3 style="list-style:none; text-align:center; margin:10px;">Dati anagrafici</h3>                   
            <table class="tabella">
                
                <tr>
                    <th>Sesso</th>
                    <th>Data di nascita</th>
                    <th>Luogo di nascita</th>
                    <th>Data di morte</th>
                    <th>Luogo di morte</th>
                </tr>
                {   
                    for $xml in $xmlCollection/*
                    let $find_testimone := $xml//tei:person[@role="testimone"]
                    let $nome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:forename)
                    let $cognome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:surname[1])
                    
                    (: sesso del testimone :)
                    let $sesso := data($find_testimone//tei:sex[1])
                    (: data e luogo di nascita :)
                    let $datanascita := data($find_testimone//tei:birth/tei:date[1])
                    
                    let $luogonascita := 
                        let $luogocompleto := data(concat($find_testimone/tei:birth/tei:placeName/tei:settlement[@type="municipality" or @type="island" or @type="town" or @type="city" or @type="città"], ", ", $find_testimone//tei:birth/tei:placeName/tei:country))
                        return $luogocompleto[1]
                    
                    (: data e luogo di morte :)
                    let $datamorte := data($find_testimone//tei:death/tei:date[1])
                    let $luogomorte := 
                        let $luogocompleto := data(concat($find_testimone/tei:death/tei:placeName/tei:settlement[@type="municipality" or @type="island" or @type="town" or @type="city" or @type="città"], ", ", $find_testimone//tei:death/tei:placeName/tei:country))
                        return $luogocompleto[1]
                    
                    (:  let $nascita:=concat($find_testimone//tei:birth/tei:date," - ",$find_testimone/tei:birth/tei:placeName/tei:settlement[@type="municipality" or @type="island" or @type="town" or @type="city" or @type="città"], ", ", $find_testimone//tei:birth/tei:placeName/tei:country)
                    let $morte:=concat($find_testimone//tei:death/tei:date," - ",$find_testimone/tei:death/tei:placeName/tei:settlement[@type="municipality" or @type="island" or @type="town" or @type="city" or @type="città"], ", ", $find_testimone//tei:death/tei:placeName/tei:country):)
       
                        where $cognome_testimone = $testimone_split[1] and $nome_testimone = $testimone_split[last()]
                 return 
                     <tr>
                         <td>{if (empty($sesso)) then '/' else $sesso}</td>
                         <td>{if (empty($datanascita)) then '/' else $datanascita}</td>
                         <td>{if (empty($luogonascita)) then '/' else $luogonascita}</td>
                         <td>{if (empty($datamorte)) then '/' else $datamorte}</td>
                         <td>{if (empty($luogomorte)) then '/' else $luogomorte}</td>
                     </tr>}
            </table>
            </div>-->
        </div>
        
        
};


declare function app:grafo_relazioni($node as node(), $model as map(*)){
    let $testimone :=request:get-parameter("testimone","")
    let $testimone_split :=tokenize($testimone,"\s")
    let $nome_testimone := concat($testimone_split[last()]," ",$testimone_split[1])

    let $xmlCollection:=collection("/db/apps/voci_inferno/xml")

    (:  vecchia funzione
        :let $lista_relazioni := 
        for $filexml in $xmlCollection/*
        let $find_testimone := $filexml//tei:person[@role="testimone"]
        let $nome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:forename)
        let $cognome_testimone:=fn:normalize-space($find_testimone/tei:persName/tei:surname[1])
        
        let $relazioni := $filexml//tei:standOff/tei:listRelation//tei:relation (: lista delle relazioni :)
        
        where $cognome_testimone = $testimone_split[1] and $nome_testimone = $testimone_split[last()]
        
        return $relazioni :)
        
    let $lista_relazioni_raw := 
        for $filexml in $xmlCollection/*
            let $find_testimone := $filexml//tei:person[@role="testimone"]
            let $nome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:forename)
            let $cognome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:surname[1])
            
            let $relazioni := $filexml//tei:standOff/tei:listRelation//tei:relation (: lista delle relazioni :)
            
            where $cognome_testimone = $testimone_split[1] and $nome_testimone = $testimone_split[last()]
            return $relazioni

    (: tolgo i duplicati: stessa coppia active/passive :)
    let $lista_relazioni :=
        for $r in $lista_relazioni_raw
            let $chiave := concat(data($r//@active), "||", data($r//@passive))
            group by $chiave
            return $r[1]
    
    let $lista_persone := 
        for $filexml in $xmlCollection/*
        let $find_testimone := $filexml//tei:person[@role="testimone"]
        let $nome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:forename)
        let $cognome_testimone:=fn:normalize-space($find_testimone/tei:persName/tei:surname[1])
        
        let $persone := $filexml//tei:standOff/tei:listPerson//tei:person  (: lista delle persone :)
        
        where $cognome_testimone = $testimone_split[1] and $nome_testimone = $testimone_split[last()]
        return $persone
        
    
    return
        
        <div>
            
            <head>
                
                <!-- Link per importare la libreria di Highcharts -->
                
                <!-- mappe -->
                <script src="https://code.highcharts.com/maps/highmaps.js"></script>
                <script src="https://code.highcharts.com/maps/modules/exporting.js"></script>
                <script src="https://code.highcharts.com/maps/modules/offline-exporting.js"></script>
                <script src="https://code.highcharts.com/maps/modules/accessibility.js"></script>
                <script src="https://code.highcharts.com/maps/modules/data.js"></script>
                <script src="https://code.highcharts.com/maps/modules/flowmap.js"></script>
                

                
                <!-- grafo -->
                <script src="https://code.highcharts.com/highcharts.js"></script>
                <script src="https://code.highcharts.com/modules/treemap.js"></script>
                <script src="https://code.highcharts.com/modules/treegraph.js"></script>      
                <script src="https://code.highcharts.com/modules/networkgraph.js"></script>
                <script src="https://code.highcharts.com/modules/timeline.js"></script>

            </head>
            
            <div id="grafo_relazioni" style="margin: 2%;">
            
            
                {
                
                    let $relations := for $relation in $lista_relazioni
                        let $passive := tokenize($relation/@passive, '#')[last()]
                        let $active := tokenize($relation/@active, '#')[last()]
                        let $role := data($relation/@name)
                        
                        let $nome_passivo := distinct-values(
                            for $person in $lista_persone 
                                let $nome_persona := $person/tei:persName/tei:forename
                                let $cognome_persona := normalize-space($person/tei:persName/tei:surname)
                                where $person/@xml:id = data($passive)
                                let $risultato := concat($nome_persona, " ", $cognome_persona)
                                return $risultato 
                        )
                         
                        let $nome_attivo := distinct-values(
                            for $person in $lista_persone 
                                let $nome_persona := $person/tei:persName/tei:forename
                                let $cognome_persona :=  normalize-space($person/tei:persName/tei:surname[1])
                                where $person/@xml:id = $active
                                let $risultato := concat($nome_persona, " ", $cognome_persona)
                                return $risultato 
                        )
                            
                        return map {
                            "from": $nome_passivo,
                            "to": $nome_attivo,
                            "link": $role
                        }
                    
                        let $json_relations := fn:serialize(
                        $relations,
                        map { 
                            "method": "json", 
                            "encoding": "UTF-8",
                            "media-type": "text/json", 
                            "indent": true() 
                        }
                    )    

                    return 
                    if (empty($relations)) then
                        <div style="text-align: center; padding: 20px; font-size: 16px; color: #666;">
                            Non sono presenti i dati necessari per visualizzare le relazioni del testimone.
                        </div>
                    else   
                        <figure class="highcharts-figure">
                            <div id="grafo_rel" style="width: 100%; height: 700px;">
                                <script>
                                    {
  
                                    "Highcharts.chart('grafo_rel', {",
                                        "chart: {",
                                            "type: 'networkgraph',",
                                            "height: '70%',",
                                            "margin: [50, 50, 50, 50]",
                                        "},",
                                        "title: {",
                                            "text: 'Grafo delle relazioni presenti nelle testimonianze di ", $nome_testimone, "',",
                                            "align: 'center',",
                                            "style: {",
                                                    "fontSize: '23px'",
                                            "}",
                                        "},",
                                        "plotOptions: {",
                                            "networkgraph: {",
                                                "keys: ['from', 'to', 'link'],",
                                                "link: {",
                                                    "color: 'grey',",
                                                    "width: 4,",
                                                    "dashStyle: 'Solid',",
                                                    "tooltip: {", 
                                                        "pointFormat: '<b>{point.link}</b><br>{point.tooltip}'",
                                                    "},",
                                                    "enable:true",
                                                "},",
                                                "marker: {",
                                                    "radius: 25,",
                                                    "lineWidth: 1,",
                                                    "lineColor: 'grey',",
                                                    "fillColor: '#04395F',",
                                                "},",
                                                "layoutAlgorithm: {",
                                                    "enableSimulation: false,",
                                                    "linkLength: 40,",
                                                    "friction: 0.5,",
                                                "},",
                                            "}",
                                        "},",
                                        "series: [{",
                                            "accessibility: { enabled: false },",
                                            "dataLabels: {",
                                                "enabled: true,",
                                                "linkFormat: '{point.link}',",
                                                "allowOverlap: true,",
                                                "crop: false,",
                                                "style: {",
                                                    "fontSize: '0.9em',",
                                                    "color: 'white',",
                                                "}",
                                            "},",
                                            "id: 'lang-tree',",
                                            "data: ", $json_relations,
                                        "}]",
                                    "});"
                            
                    }
            
                                </script>
                            </div>
                        </figure>
                }
            </div>

            <h3 style="text-align:center;margin-bottom:25px; margin:2%; padding-left:50px;padding-right:50px;">Tabella delle relazioni</h3>
                                         
            <div id="tabella_organizzazioni" class="section_tabella" style="margin:2%;">
                
                                    
                <table class="tabella" style="margin:2%;">
                      <tr>
                        <th>ID referente</th>
                        <th>Nome referente</th>
                        <th>Tipo relazione</th>
                        <th>ID attivo</th>
                        <th>Nome attivo</th>
                        <th>Descrizione</th>
                      </tr>
                      
                        {
                            
                        
                            for $relation in $lista_relazioni
                            let $passive := data($relation//@passive)
                            let $role := data($relation//@name)
                            let $active := data($relation//@active)
                            let $desc := data($relation)
                            let $id_passivo := tokenize($passive, '#')[last()]
                            let $id_attivo := tokenize($active, '#')[last()]
                            
                                let $nome_passivo := distinct-values(
                                    for $person in $lista_persone 
                                    let $nome_persona := $person/tei:persName/tei:forename
                                    let $cognome_persona := $person/tei:persName/tei:surname[1]
                                    where $person/@xml:id = $id_passivo 
                                    let $risultato := concat($nome_persona, " ", $cognome_persona)
                                    return $risultato 
                                )
                            
                                let $nome_attivo := distinct-values( 
                                    for $person in $lista_persone 
                                    let $nome_persona := $person/tei:persName/tei:forename
                                    let $cognome_persona := $person/tei:persName/tei:surname[1]
                                    where $person/@xml:id = $id_attivo
                                    let $risultato := concat($nome_persona, " ", $cognome_persona)
                                    return $risultato 
                                )
                                
                            return
                            <tr>
                              <td>{$id_passivo}</td>
                              <td>{$nome_passivo}</td>
                              <td>{$role}</td>
                              <td>{$id_attivo}</td>
                              <td>{$nome_attivo}</td>
                              <td>{$desc}</td>
                            </tr>
                            
                         }
                    </table>
                    
                </div>
                
        </div>
    
};


(: funzione per la mappa degli spostamenti :)

declare function app:mappa_spostamenti($node as node(), $model as map(*)){
    let $testimone :=request:get-parameter("testimone","")
    let $testimone_split :=tokenize($testimone,"\s")
    let $nome_testimone := concat($testimone_split[last()]," ",$testimone_split[1])

    let $xmlCollection:=collection("/db/apps/voci_inferno/xml")

    let $lista_luoghi := 
        for $filexml in $xmlCollection/*
        let $find_testimone := $filexml//tei:person[@role="testimone"]
        let $nome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:forename)
        let $cognome_testimone:=fn:normalize-space($find_testimone/tei:persName/tei:surname[1])
        
        let $luoghi := $filexml//tei:listPlace//tei:place (: lista dei luoghi :)
        
        where $cognome_testimone = $testimone_split[1] and $nome_testimone = $testimone_split[last()]
        return $luoghi
    
    let $lista_eventi := 
        
        for $filexml in $xmlCollection/*
        
        let $find_testimone := $filexml//tei:person[@role="testimone"]
        let $nome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:forename)
        let $cognome_testimone:=fn:normalize-space($find_testimone/tei:persName/tei:surname[1])
        
        let $eventi := $filexml//tei:listEvent//tei:event (: lista degli eventi :)
        
        where $cognome_testimone = $testimone_split[1] and $nome_testimone = $testimone_split[last()]
        return $eventi
        
    return 
        <div>
            
        <div id="mappa_spostamenti" style="margin:1%;">
        <!--<h2 style="text-align:center;margin-bottom:25px; margin:2%; padding-left:50px;padding-right:50px;">Mappa degli spostamenti</h2>-->
            {
                (: ottenere nome luogo, latitudine e longitudine e dagli eventi il nome "da" a "a" :)
            
            let $mappa_luoghi_spostamenti := 
            
            for $luoghi in $lista_luoghi 
                let $nome_luogo := normalize-space($luoghi//tei:placeName)
                
                let $nome_luogo_evento := 
                for $luoghi_evento in $lista_eventi 
                    let $luogo_evento := normalize-space(data($luoghi_evento//tei:placeName))
                    return $luogo_evento
                    
                    
                let $geo := normalize-space($luoghi//tei:geo)
                let $geo_tokens := tokenize($geo, '\s+')
                let $geo_luogo_lat := xs:decimal($geo_tokens[1])
                let $geo_luogo_long := xs:decimal($geo_tokens[2])
                where normalize-space($nome_luogo) != '' and exists($geo_luogo_lat) and exists($geo_luogo_long) and $nome_luogo = $nome_luogo_evento
                return
                    map {
                      "id": $nome_luogo,
                      "lat": $geo_luogo_lat,
                      "lon": $geo_luogo_long
                    }
                let $json_luoghi := fn:serialize(
                  $mappa_luoghi_spostamenti,
                  map { 
                      "method": "json", 
                      "encoding": "UTF-8",
                      "media-type": "text/json", 
                      "indent": true() 
                     }
                )


            let $mappa_spostamenti := 
                    for $i in $lista_eventi 
                    let $id_evento := data($i/@xml:id)
                    
                    let $luogo_from := 
                        for $rel in $i//tei:listRelation/tei:relation
                        let $active_id := tokenize(data($rel/@active), "#")[2]
                        where $active_id = $id_evento
                        return normalize-space($i//tei:placeName) (: Nome del luogo di partenza :)
                
                    let $next_event := $i/following-sibling::tei:event[1]
                    where count($next_event) > 0
                    
                    let $nome_evento := 
                        for $rel in $i//tei:listRelation/tei:relation
                        let $active_id := tokenize(data($rel/@active), "#")[2]
                        where $active_id = $id_evento
                        return normalize-space($next_event//tei:eventName)
                    
                    let $note_evento := 
                        for $rel in $i//tei:listRelation/tei:relation
                        let $active_id := tokenize(data($rel/@active), "#")[2]
                        where $active_id = $id_evento
                        return normalize-space(($next_event//tei:note, ' ')[1])
                        
                    let $desc := concat('<b>', $nome_evento, '</b>:', $note_evento)
                
                    let $luogo_to := 
                        for $rel in $i//tei:listRelation/tei:relation
                        let $passive_id := tokenize(data($rel/@passive), "#")[2]
                        where $passive_id = $next_event/@xml:id                        
                        (: Controlla se il passive corrisponde all'id del prossimo evento :)
                        return normalize-space($next_event//tei:placeName) (: Nome del luogo di arrivo dal successivo evento :)
                    
                    (: se l'event non contiene una relazione di spostamento, non ci sono luoghi di partenza nè di arrivo "from" "to" allora non lo mette nell'array map degli spostamenti :)
                    return if (empty($luogo_from))
                    then ()
                    else map {
                            "from": $luogo_from,
                            "to":$luogo_to,
                            "description": $desc
                            }
                    
                    
                        
                            
                    let $json_spostamenti := fn:serialize(
                        $mappa_spostamenti,
                          map { 
                              "method": "json", 
                              "encoding": "UTF-8",
                              "media-type": "text/json", 
                              "indent": true() 
                            }
                        )

  
            return
            if (empty($mappa_luoghi_spostamenti)) then
                <div style="text-align: center; padding: 20px; font-size: 16px; color: #666;">
                    Non sono presenti i dati necessari per visualizzare la mappa degli spostamenti del testimone.
                </div>
            else 
                    
                    <div>
                        
                    <!--{$mappa_luoghi1}
                    {$risultato}-->
                    <figure class="highcharts-figure">
                        <div id="mappa-spostamenti" style="width: 100%; height: 700px;"></div>
                    <!--  <pre>{$json_spostamenti}</pre><p>Eventi: {count($lista_eventi)}</p> -->
                        <script>
                            {
                                    "(async () => {",
                                        "const topology = await fetch('https://code.highcharts.com/mapdata/custom/europe.topo.json')",
                                        "    .then(response => response.json());",
                            
                                        "Highcharts.mapChart('mappa-spostamenti', {",
                                            "chart: {",
                                                "map: topology,",
                                            "},",
                                            "title: {",
                                                "text: 'Mappa degli spostamenti di ", $nome_testimone, "',",
                                                "align: 'center',",
                                                    "style: {",
                                                            "fontSize: '23px'",
                                                "}",
                                            "},",
                                            "mapNavigation: {",
                                                "enabled: true,",
                                            "},",
                                            "accessibility: {",
                                                "point: {",
                                                    "valueDescriptionFormat: '{xDescription}.',",
                                                "},",
                                            "},",
                                            "plotOptions: {",
                                                "flowmap: {",
                                                    "tooltip: {",
                                                        "headerFormat: null,",
                                                        "pointFormat: '{point.options.from} \u2192 {point.options.to} <br> {point.options.description}'",
                                                    "},",
                                                "},",
                                                "mappoint: {",
                                                    "tooltip: {",
                                                        "headerFormat: '{point.point.id}<br>',",
                                                        "pointFormat: 'Lat: {point.lat} Lon: {point.lon}',",
                                                    "},",
                                                    "showInLegend: false,",
                                                    "marker: {",
                                                        "radius: 5,",
                                                    "}",
                                                "}",
                                            "},",
                                            "series: [{",
                                                "name: 'Basemap',",
                                                "showInLegend: false,",
                                                "borderColor: '#A0A0A0',",
                                                "nullColor: 'rgba(200, 200, 200, 0.3)',",
                                                "fillOpacity: 1,",
                                                "states: {",
                                                    "inactive: { enabled: false },",
                                                "},",
                                                "data: [['qa', 1]],",
                                            "}, {",
                                                "type: 'mappoint',",
                                                "name: 'Countries',",
                                                "color: Highcharts.getOptions().colors[1],",
                                                "dataLabels: { format: '{point.id}' },",
                                                "data: ", $json_luoghi, ",",
                                            "}, {",
                                                "type: 'flowmap',",
                                                "name: 'Flowmap Series',",
                                                "accessibility: {",
                                                    "point: {",
                                                        "valueDescriptionFormat: 'Origin: {point.options.from:.2f}, Destination: {point.options.to:.2f}.'",
                                                    "},",
                                                    "description: 'Questa è una mappa che mostra i luoghi e gli spostamenti del testimone',",
                                                "},",
                                                "fillOpacity: 1,",
                                                "width: 1,",
                                                "color: '#550d6566',",
                                                "lineWidth: 1.5,",
                                                "data: ", $json_spostamenti, ",",
                                            "}]",
                                        "});",
                                    "})();"
                            }

                        </script>
                    </figure>
                    </div>
            }
        </div>
        
        </div>
};

(: funzione per la mappa dei luoghi :)

declare function app:mappa_luoghi($node as node(), $model as map(*)){
    let $testimone :=request:get-parameter("testimone","")
    let $testimone_split :=tokenize($testimone,"\s")
    let $nome_testimone := concat($testimone_split[last()]," ",$testimone_split[1])

    let $xmlCollection:=collection("/db/apps/voci_inferno/xml")

    let $lista_luoghi := 
        for $filexml in $xmlCollection/*
        let $find_testimone := $filexml//tei:person[@role="testimone"]
        let $nome_testimone := fn:normalize-space(string-join($find_testimone/tei:persName/tei:forename,'-'))
        let $cognome_testimone:=fn:normalize-space($find_testimone/tei:persName/tei:surname[1])
        
        let $luoghi := $filexml//tei:listPlace//tei:place (: lista dei luoghi :)
        
        where $cognome_testimone = $testimone_split[1] and $nome_testimone = $testimone_split[last()]
        return $luoghi
    
    return 
        
    <div>
        
            <div id="mappa_luoghi" style="margin:1%;">

        {
            let $mappa_luoghi := 
            for $luoghi in $lista_luoghi
            
                let $nome_luogo := normalize-space($luoghi//tei:placeName[1])
                let $stato_luogo := normalize-space($luoghi//tei:country[1])
                let $geo := $luoghi//tei:geo
                let $geo_tokens := tokenize($geo, '\s+')
                let $geo_luogo_lat := xs:decimal($geo_tokens[1])
                let $geo_luogo_long := xs:decimal($geo_tokens[2])
                let $link_luogo :=  if ($luoghi/@source) then
                                        normalize-space($luoghi/@source)
                                    else
                                        normalize-space($luoghi/tei:ptr/@target)
                let $note_luogo := normalize-space($luoghi/tei:note)
                where exists($nome_luogo) and exists($geo_luogo_lat) and exists($geo_luogo_long)
                return 
                    map {
                        "name": $nome_luogo,
                        "lat": $geo_luogo_lat,
                        "lon": $geo_luogo_long,
                        "link": $link_luogo,
                        "description": $note_luogo,
                        "country": $stato_luogo
                        }
                let $json_listaluoghi := fn:serialize(
                  $mappa_luoghi,
                  map { 
                      "method": "json", 
                      "encoding": "UTF-8",
                      "media-type": "text/json", 
                      "indent": true() 
                     }
                )
                 
            return
            if (empty($mappa_luoghi)) then
                <div style="text-align: center; padding: 20px; font-size: 16px; color: #666;">
                    Non sono presenti i dati necessari per visualizzare la mappa dei luoghi del testimone.
                </div>
            else 
               
                    <figure class="highcharts-figure">
                        <div id="mappa_luoghi_unico" style="width: 100%; height: 700px;"></div>
                        
                        <script>
                          {
                            "(async () => {",
                                "const topology = await fetch('https://code.highcharts.com/mapdata/custom/world-highres.topo.json')",
                                ".then(response => response.json());",
                    
                                "Highcharts.mapChart('mappa_luoghi_unico', {",
                                    "chart: {",
                                        "map: topology",
                                    "},",
                                    "title: {",
                                        "text: 'Mappa dei luoghi presenti nelle testimonianze di ", $nome_testimone, "',",
                                        "align: 'center',",
                                        "style: {",
                                            "fontSize: '23px'",
                                        "}",
                                    "},",
                                    "accessibility: {",
                                        "description: 'Map where city locations have been defined using ' +",
                                        "'latitude/longitude.'",
                                    "},",
                                    "mapNavigation: {",
                                        "enabled: true",
                                    "},",
                                    "tooltip: {",
                                        "headerFormat: '',",
                                        "pointFormat: '<b>{point.name}</b><br/>{point.country}<br/><small>Lat: {point.lat}, Lon: {point.lon}</small><br/>{point.description}'",
                                    "},",
                                    "series: [{",
                                        "name: 'Europe',",
                                        "borderColor: '#A0A0A0',",
                                        "nullColor: 'rgba(200, 200, 200, 0.3)',",
                                        "showInLegend: false,",
                                    "}, {",
                                        "name: 'Separators',",
                                        "type: 'mapline',",
                                        "nullColor: '#707070',",
                                        "showInLegend: false,",
                                        "enableMouseTracking: false,",
                                        "accessibility: {",
                                            "enabled: false,",
                                        "}",
                                    "}, {",
                                        "type: 'mappoint',",
                                        "name: 'World',",
                                        "accessibility: {",
                                            "point: {",
                                                "valueDescriptionFormat: '{xDescription}. Lat: {point.lat:.2f}, lon: {point.lon:.2f}, Link: {point.link}, {point.description}.'",
                                            "}",
                                        "},",
                                        "color: Highcharts.getOptions().colors[1],",
                                        "data: ", $json_listaluoghi, ",",
                                        
                                        "events: {",
                                            "click: function(event) {",
                                                "const point = event.point;",
                                                "console.log('this:', this);",
                                                "console.log('Clicked point:', point);", 
                                                "if (point &amp;&amp; point.link) {",
                                                    "window.open(point.link, '_blank');",
                                                "} else {",
                                                    "console.log('Link non trovato');",
                                                "}",
                                            "}",
                                        "}",
    
                                    "}]",
                                "});",
                            "})();"
                        }
                        </script> 
                    </figure>
                    }
            </div>
            
        
    </div>
};


declare function app:linea_temporale($node as node(), $model as map(*)) {
    let $testimone := request:get-parameter("testimone","")
    let $testimone_split := tokenize($testimone,"\s")
    let $nome_testimone := concat($testimone_split[last()]," ",$testimone_split[1])
    
    let $xmlCollection := collection("/db/apps/voci_inferno/xml")
    
    let $lista_eventi := 
        for $filexml in $xmlCollection/*
        let $find_testimone := $filexml//tei:person[@role="testimone"]
        let $nome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:forename)
        let $cognome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:surname[1])
        
        let $eventi := $filexml//tei:listEvent//tei:event
        
        where $cognome_testimone = $testimone_split[1] and $nome_testimone = $testimone_split[last()]
        return $eventi
        
    return
        
    <div>
        <div id="linea_temporale" style="margin:1%;">
        {
            let $eventi_raw :=
                for $evento in $lista_eventi
                    let $data := normalize-space($evento/@when)
                    (: string-join per non dare errore se ci fosse più di un evento :)
                    let $nome_evento := normalize-space(string-join($evento//tei:eventName, " "))
                    let $note_evento := normalize-space(string-join($evento//tei:note, " "))
                    where $data != ''
                    return
                        map {
                            "data": $data,
                            "nome": $nome_evento,
                            "note": $note_evento
                            }
                
                (: rimuovo i duplicati: stesso evento (data uguale) ripetuto :)
                let $eventi_distinct :=
                    for $e in $eventi_raw
                    let $chiave := $e?data
                    group by $chiave
                    return $e[1]
                
                (: ordino cronologicamente per data (formato ISO, quindi ordinabile come stringa) :)
                let $linea_temporale :=
                    for $e in $eventi_distinct
                    order by $e?data (: prendo il vslore di data in map :)
                    return
                        map {
                            "name": concat ("<b>", $e?data, ":</b> ", $e?nome),
                            "description": $e?note
                            }
            
            
            (:  let $linea_temporale :=
            for $evento in $lista_eventi
                let $data := normalize-space($evento/@when)
                let $nome_evento := normalize-space($evento//tei:eventName)
                let $note_evento := normalize-space(string-join($evento//tei:note, " "))
                where normalize-space($data) != ''
                return
                    map {
                        "name": concat ("<b>", $data, ":</b> ", $nome_evento),
                        "description": $note_evento
                        }:)
                    let $json_lineatemp := fn:serialize(
                        $linea_temporale,
                        map { 
                            "method": "json", 
                            "media-type": "text/json", 
                            "indent": true() 
                            }
                    )
            return
            if (empty($linea_temporale)) then
                <div style="text-align: center; padding: 20px; font-size: 16px; color: #666;">
                    Non sono presenti i dati necessari per visualizzare la linea temporale del testimone.
                </div>
            else                                   
            <div>
                <figure class="highcharts-figure">
                    <div id="linea_temporale_chart" style="width: 100%; height: 500;"></div>
                    <script>
                        {
                            "Highcharts.chart('linea_temporale_chart', {",
                                "chart: {",
                                    "type: 'timeline'",
                                "},",
                                "xAxis: {",
                                    "visible: false",
                                "},",
                                "yAxis: {",
                                    "visible: false",
                                "},",
                                "title: {",
                                    "text: 'Timeline degli eventi di ", $nome_testimone, "'",
                                "},",
                                "colors: [",
                                    "'#4185F3',",
                                    "'#427CDD',",
                                    "'#406AB2',",
                                    "'#3E5A8E',",
                                    "'#3B4A68',",
                                    "'#363C46'",
                                "],",
                                "tooltip: {",
                                    "style: {",
                                        "width: 300",
                                    "}",
                                "},",
                                "plotOptions: {",
                                  "timeline: {",
                                    "dataLabels: {",
                                      "style: {",
                                        "fontSize: '12px',",
                                        "width: '200px'" ,      
                                      "},",
                                      "padding: 4",             
                                    "}",
                                  "}",
                                "},",
                                "series: [{",
                                    "data: ", $json_lineatemp, ",",
                                "}]",
                            "});"
                        }
                    </script>
                </figure>

                
            </div>
}
        </div>
    </div>
};

declare function app:ConsultaTestimonianza($node as node(), $model as map(*)){
    let $titolotestimonianza := request:get-parameter("titolotestimonianza", "")
    
    let $xmlCollection := collection("/db/apps/voci_inferno/xml")
    let $filexml := 
        for $xml in $xmlCollection/*
        let $titolo := fn:normalize-space($xml//tei:title[@xml:id="titolotestimonianza"])
        where $titolo = $titolotestimonianza
        return $xml
        
    let $testimonianzaorale := $filexml//tei:sourceDesc/tei:recordingStmt (: orale o scritta :)
    
    let $testimone := concat($filexml//tei:person[@role="testimone"]//tei:persName//tei:forename," ",$filexml//tei:person[@role="testimone"]//tei:persName//tei:surname[1])
    
    let $tipologia_scritto:=$filexml//tei:fileDesc//tei:sourceDesc//tei:msDesc//tei:physDesc//tei:objectDesc
    
    let $encoder:=$filexml//tei:fileDesc//tei:editionStmt//tei:respStmt[@xml:id="encoder"]//tei:persName
    
    let $tipo :=
    
        (: SE E' UNA TESTIMONIANZA SCRITTA :)
        if (fn:empty($testimonianzaorale)) then 
            
            (: controllo il tipo di fonte scritta :)
            
            (: se è una lettera o un insieme di lettere :)
            if ($tipologia_scritto/@form="letters") then
                
                let $data:=$filexml//tei:profileDesc//tei:creation//tei:date
                let $lang := $filexml//tei:profileDesc//tei:language 
                let $source:=data($filexml//tei:fileDesc//tei:sourceDesc/tei:msDesc//tei:physDesc//tei:supportDesc/@source)
                let $idno:=$filexml//tei:fileDesc//tei:sourceDesc/tei:msDesc//tei:msIdentifier//tei:idno
            

                return
                    <div class="box">
                        <h2>{$testimone}</h2>
                        <h3 id="titolo">{$titolotestimonianza}</h3>
                        <div class="info">
                            <p><b>Fonte</b>: scritta</p>
                            <p><b>Tipologia</b>: lettera/e</p>
                            <p><b>Data:</b> {$data}</p>
                            <p><b>Lingue:</b> {$lang}</p>
                            <p><b>Source</b>: { if ($source) then <a href="{$source}" target="blank">{$source}</a>  else "/"}</p>
                            <p><b>Codice identificativo</b>: {$idno}</p>
                            <p><b>Trascrizione e codifica a cura di:</b> {$encoder}</p>
                            
                        </div>
                        
                        <div class="button_sezioni">
                            <div class="leggi_testimonianza">
                                <button onclick="VaiAllaTestimonianza()">Leggi la testimonianza</button>
                            </div>
                            <div class="vedi_statistiche_testimonianza">
                                <button onclick="VaiStatisticheTestimonianza()">Consulta le statistiche</button>
                            </div>
                            <div class="ricerca_dante">
                                <button onclick="VaiRicercaDante()">Il dante di {$testimone}</button>
                            </div>
                        </div>
                    </div>
                
            (: se è un diario :)
            else if ($tipologia_scritto/@form="manuscript_diary") then
                
                    let $data:=$filexml//tei:profileDesc//tei:creation//tei:date
                    let $lang := $filexml//tei:profileDesc//tei:language 
                    let $materiale:=$filexml//tei:fileDesc//tei:sourceDesc/tei:msDesc//tei:physDesc//tei:objectDesc//tei:material
                    let $source:=data($filexml//tei:fileDesc//tei:sourceDesc/tei:msDesc//tei:physDesc//tei:supportDesc/@source)
                    let $idno:=$filexml//tei:fileDesc//tei:sourceDesc/tei:msDesc//tei:msIdentifier//tei:idno
                    
                    return
                        <div class="box">
                            <h2>{$testimone}</h2>
                            <h3 id="titolo">{$titolotestimonianza}</h3>
                            <div class="info">
                                <p><b>Fonte</b>: scritta</p>
                                <p><b>Tipologia</b>: diario</p>
                                <p><b>Data:</b> {$data}</p>
                                <p><b>Lingue:</b> {$lang}</p>
                                <p><b>Materiale:</b>{$materiale}</p>
                                <p><b>Source</b>: { if ($source) then <a href="{$source}" target="blank">{$source}</a>  else "/"}</p>
                                <p><b>Codice identificativo</b>: {if ($idno) then ($idno) else "/"}</p>
                                <p><b>Trascrizione e codifica a cura di:</b> {$encoder}</p>
                                
                                
                            </div>
                            
                            <div class="button_sezioni">
                                <div class="leggi_testimonianza">
                                    <button onclick="VaiAllaTestimonianza()">Leggi la testimonianza</button>
                                </div>
                                <div class="vedi_statistiche_testimonianza">
                                    <button onclick="VaiStatisticheTestimonianza()">Consulta le statistiche</button>
                                </div>
                                <div class="ricerca_dante">
                                    <button onclick="VaiRicercaDante()">Il dante di {$testimone}</button>
                                </div>
                            </div>
                        </div>
                        
            
            else if ($tipologia_scritto/@form="dossier") then
                
                    let $data:=$filexml//tei:profileDesc//tei:creation//tei:date
                    let $lang := $filexml//tei:profileDesc//tei:language 
                    let $source:=data($filexml//tei:fileDesc//tei:sourceDesc/tei:msDesc//tei:physDesc//tei:supportDesc/@source)
                    let $idno:=$filexml//tei:fileDesc//tei:sourceDesc/tei:msDesc//tei:msIdentifier//tei:idno
                    
                    return
                        <div class="box">
                            <h2>{$testimone}</h2>
                            <h3 id="titolo">{$titolotestimonianza}</h3>
                            <div class="info">
                                <p><b>Fonte</b>: scritta</p>
                                <p><b>Tipologia</b>: fascicolo</p>
                                <p><b>Data:</b> {$data}</p>
                                <p><b>Lingue</b>: {$lang}</p>
                                <p><b>Source</b>: { if ($source) then <a href="{$source}" target="blank">{$source}</a>  else "/"}</p>
                                <p><b>Codice identificativo</b>: {if ($idno) then ($idno) else "/"}</p>
                                <p><b>Trascrizione e codifica a cura di:</b> {$encoder}</p>
                            </div>
                            
                            <div class="button_sezioni">
                                <div class="leggi_testimonianza">
                                    <button onclick="VaiAllaTestimonianza()">Leggi la testimonianza</button>
                                </div>
                                <div class="vedi_statistiche_testimonianza">
                                    <button onclick="VaiStatisticheTestimonianza()">Consulta le statistiche</button>
                                </div>
                                <div class="ricerca_dante">
                                    <button onclick="VaiRicercaDante()">Il dante di {$testimone}</button>
                                </div>
                            </div>
                        </div> 
            
            
            else if ($tipologia_scritto/@form="manuscript_sheet") then
                
                    let $data:=$filexml//tei:profileDesc//tei:creation//tei:date
                    let $lang := $filexml//tei:profileDesc//tei:language 
                    let $materiale:=$filexml//tei:fileDesc//tei:sourceDesc/tei:msDesc//tei:physDesc//tei:objectDesc//tei:material
                    let $info_scrittura:=$filexml//tei:fileDesc//tei:sourceDesc/tei:msDesc//tei:physDesc//tei:handDesc//tei:p
                    let $source:=data($filexml//tei:fileDesc//tei:sourceDesc/tei:msDesc//tei:physDesc//tei:supportDesc/@source)
                    let $idno:=$filexml//tei:fileDesc//tei:sourceDesc/tei:msDesc//tei:msIdentifier//tei:idno
                    
                    return
                        <div class="box">
                            <h2>{$testimone}</h2>
                            <h3 id="titolo">{$titolotestimonianza}</h3>
                            <div class="info">
                                <p><b>Fonte</b>: scritta</p>
                                <p><b>Tipologia</b>: foglio manoscritto</p>
                                <p><b>Data:</b> {$data}</p>
                                <p><b>Lingue</b>: {$lang}</p>
                                <p><b>Materiale:</b>{$materiale}</p>
                                <p><b>Informazioni sulla scrittura:</b>{$info_scrittura}</p>
                                <p><b>Source</b>: { if ($source) then <a href="{$source}" target="blank">{$source}</a>  else "/"}</p>
                                <p><b>Codice identificativo</b>: {if ($idno) then ($idno) else "/"}</p>
                                <p><b>Trascrizione e codifica a cura di:</b> {$encoder}</p>
                            </div>
                            
                            <div class="button_sezioni">
                                <div class="leggi_testimonianza">
                                    <button onclick="VaiAllaTestimonianza()">Leggi la testimonianza</button>
                                </div>
                                <div class="vedi_statistiche_testimonianza">
                                    <button onclick="VaiStatisticheTestimonianza()">Consulta le statistiche</button>
                                </div>
                                <div class="ricerca_dante">
                                    <button onclick="VaiRicercaDante()">Il dante di {$testimone}</button>
                                </div>
                            </div>
                        </div>
             
                
            
            
            else
                    let $data:=$filexml//tei:profileDesc//tei:creation//tei:date
                    let $lang := $filexml//tei:profileDesc//tei:language 
                    return
                        <div class="box">
                            <h2>{$testimone}</h2>
                            <h3 id="titolo">{$titolotestimonianza}</h3>
                            <div class="info">
                                <p><b>Fonte</b>: scritta</p>
                                <p><b>Tipologia</b>: /</p>
                                <p><b>Data:</b> {$data}</p>
                                <p><b>Lingue</b>: {$lang}</p>
                                <p><b>Trascrizione e codifica a cura di:</b> {$encoder}</p>
                            </div>
                            
                            <div class="button_sezioni">
                                <div class="leggi_testimonianza">
                                    <button onclick="VaiAllaTestimonianza()">Leggi la testimonianza</button>
                                </div>
                                <div class="vedi_statistiche_testimonianza">
                                    <button onclick="VaiStatisticheTestimonianza()">Consulta le statistiche</button>
                                </div>
                                <div class="ricerca_dante">
                                    <button onclick="VaiRicercaDante()">Il dante di {$testimone}</button>
                                </div>
                            </div>
                        </div> 
            
                
         
        (: SE E' UNA TESTIMONIANZA ORALE :)      
        else 
            let $tipo := distinct-values(data($filexml//tei:recordingStmt/tei:recording/@type) ) (: aggiungo distinct-values per non ripetere l'informazione poichè sono 2 cassette :)
            let $data := distinct-values($filexml//tei:recordingStmt/tei:recording/tei:date) (: data registrazione :)  (: aggiungo distinct-values per non ripetere l'informazione poichè sono 2 cassette :)
            let $resp := distinct-values($filexml//tei:recordingStmt//tei:respStmt/tei:name) (: nome responsabile intervista - tei:name perchè non è detto che sia una persona. Es. Telepace :)
            let $lang := $filexml//tei:profileDesc//tei:language (: lingue testimonianza :)
            let $note := distinct-values($filexml//tei:recordingStmt//tei:respStmt/tei:note) (: note :)
            let $link:=distinct-values(data($filexml//tei:broadcast//tei:bibl//@source))
            
            let $n_cassette:=count($filexml//tei:recordingStmt/tei:recording/tei:date)
            
            let $durate := $filexml//tei:recordingStmt//tei:recording/@dur
            let $time:=                
                for $durata in $durate
                let $durata-in-secondi := xs:duration($durata)
                let $ore := floor(hours-from-duration($durata-in-secondi))
                let $minuti := floor(minutes-from-duration($durata-in-secondi)) mod 60
                let $secondi := round(seconds-from-duration($durata-in-secondi)) mod 60
                let $time := concat($ore, " ore ", $minuti," minuti ", $secondi, " secondi ")
            return $time
            
           

            return
                <div class="box">
                    <h2 id="titolo">{$testimone}</h2>
                    <h3 id="titolo">{$titolotestimonianza}</h3>
                        
                    <div class="info">
                        <p><b>Fonte</b>: orale</p>
                        <p><b>Tipologia</b>: {$tipo}</p>
                        <!--<p><b>Link: </b> {if ($link) then <a href="{$link}" target="blank">{$link}</a> else "/"}</p>-->
                        <p><b>Link: </b> {<a href="{$link}" target="blank">{$link}</a> }</p>
                        <p><b>Numero cassette</b>: {$n_cassette}</p>
                        <p><b>Durata</b>: {string-join($time, " / ")}</p>
                        <p><b>Data</b>: {$data}</p>
                        <p><b>Realizzata da</b>: {$resp}</p>
                        <p><b>Lingue</b>: {$lang}</p>
                        <p><b>Note</b>: {if ($note) then ($note) else "/"}</p>
                        <p><b>Trascrizione e codifica a cura di:</b> {$encoder}</p>
                    </div>
                    
                    
                    <div class="button_sezioni">
                        <div class="leggi_testimonianza">
                            <button onclick="VaiAllaTestimonianza()">Leggi la testimonianza</button>
                        </div>
                        <div class="vedi_statistiche_testimonianza">
                            <button onclick="VaiStatisticheTestimonianza()">Consulta le statistiche</button>
                        </div>
                        <div class="ricerca_dante">
                            <button onclick="VaiRicercaDante()">Il dante di {$testimone}</button>
                        </div>
                    </div>
                </div>
    return $tipo
};





declare function app:ContaRegesti($node as node(), $model as map(*)){
    let $titolotestimonianza :=request:get-parameter("titolotestimonianza","")
    
    let $xmlCollection:=collection("/db/apps/voci_inferno/xml")
    let $filexml := 
        for $xml in $xmlCollection/*
        let $titolo := fn:normalize-space($xml//tei:title[@xml:id="titolotestimonianza"])
        where $titolo = $titolotestimonianza
        return $xml

    let $testimonianzaorale:=$filexml//tei:sourceDesc/tei:recordingStmt    (: orale o scritta :)

    (: controllo il tipo di testimonianza: se è orale conto il numero di regesto :)
    let $tipo:=
        if (fn:empty($testimonianzaorale))   (: SE E' UNA TESTIMONIANZA SCRITTA :)
        then 
            ()
        else
            let $numregesto := count(
                let $timelineregesto:=$filexml//tei:timeline[@xml:id="TL1"]
                return $timelineregesto//tei:when
            ) 
            
            return 
                <div>
                    <h2>Regesto</h2>
                    <p style="text-transform: uppercase; margin-top:20px; margin-bottom:30px;">Il regesto di questa testimonianza è composto da <b>{$numregesto}</b> parti</p>
                </div>
    return $tipo
    
};

declare function app:RestituisciRegesto($node as node(), $model as map(*)){
    
    let $titolotestimonianza :=request:get-parameter("titolotestimonianza","")
    
    let $xmlCollection:=collection("/db/apps/voci_inferno/xml")
    let $filexml := 
        for $xml in $xmlCollection/*
        let $titolo := fn:normalize-space($xml//tei:title[@xml:id="titolotestimonianza"])
        where $titolo = $titolotestimonianza
        return $xml
    

    
    let $testimonianzaorale:=$filexml//tei:sourceDesc/tei:recordingStmt    (: orale o scritta :)
    let $timelineregesto:=$filexml//tei:timeline[@xml:id="TL1"]
    let $lista_item:=$filexml//tei:abstract/tei:ab/tei:list/tei:item
    
    
    
  let $testimone:=
    for $xml in $xmlCollection/*
    let $titolo := fn:normalize-space($xml//tei:title[@xml:id="titolotestimonianza"])
    
    let $find_testimone := $xml//tei:person[@role="testimone"]
    let $nome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:forename)
    let $cognome_testimone:=fn:normalize-space(string-join($find_testimone/tei:persName/tei:surname, " "))
    let $testimone :=concat($nome_testimone," ",$cognome_testimone)
    
    where $titolo = $titolotestimonianza
    return $testimone
    
    let $testimone_:= replace($testimone, "\s+", "_")

    (: controllo il tipo di testimonianza: se è orale restituisco il regesto :)
    let $tipo :=
    if (fn:empty($testimonianzaorale)) (: SE E' UNA TESTIMONIANZA SCRITTA :)
    then 
        ()
    else
        let $regesto :=
            for $i in 1 to count($lista_item)
                let $item := $lista_item[$i]
                let $synch := $item/@synch/string()
                let $xml_id := tokenize($synch, '#')[2]
                let $inizio := $timelineregesto//tei:when[@xml:id=$xml_id]/@absolute/string()
                let $fine :=
                    if ($i < count($lista_item)) 
                    then 
                        let $synch := $lista_item[$i + 1]/@synch/string()
                        let $xml_id := tokenize($synch, "#")[2]
                        return $timelineregesto//tei:when[@xml:id=$xml_id]/@absolute/string()
                    else "continua fino alla fine dell'audio"
                
                return 
                    
                    <div class="parti_regesto">
                            
                        <p id="testo_regesto">{$item}</p>
                        <p id="durata_regesto">
                            { 
                                if ($fine = "continua fino alla fine dell'audio")
                                then concat("Questa parte inizia al minuto ", $inizio, " e ", $fine)
                                else concat("Questa parte inizia al minuto ", $inizio, " e finisce al minuto ", $fine)
                            }
                        </p>
                        
                       <audio class="audio_player" id="audio-intervista-{ $i }" controls="controls"  data-inizio="{$inizio}"   data-fine="{$fine}" ontimeupdate="{fn:concat('controllaTempo(this, ', $inizio, ', ', $fine, ')') }">
                            <source src="{ concat('https://48001.omega.ilc.cnr.it/exist/rest/apps/voci_inferno/resources/audio/', $testimone_, '.mp3') }"/>
                        </audio>

                    </div>

                   
        return $regesto

    return $tipo
   
    
};





declare function app:intervista($node as node(), $model as map(*)){
    let $titolotestimonianza :=request:get-parameter("titolotestimonianza","")
    
    
    let $xmlCollection:=collection("/db/apps/voci_inferno/xml")
    
    
    let $filexml := 
        for $xml in $xmlCollection/*
        let $titolo := fn:normalize-space($xml//tei:title[@xml:id="titolotestimonianza"])
        where $titolo = $titolotestimonianza
        return $xml

    let $testimonianzaorale:=$filexml//tei:sourceDesc/tei:recordingStmt    (: orale o scritta :)
    let $lista_u:=$filexml//tei:body//tei:u
    (:   :let $lista_who:=distinct-values($filexml//tei:body//tei:u/@who):)
    
    let $lista_who_forename:=data($filexml//tei:profileDesc//tei:particDesc//tei:listPerson//tei:persName/tei:forename)
    let $lista_who_surname:=data($filexml//tei:profileDesc//tei:particDesc//tei:listPerson//tei:persName/tei:surname)
    
    let $lista_who:=$filexml//tei:profileDesc//tei:particDesc//tei:listPerson//tei:persName
    
    let $tipologia_scritto:=$filexml//tei:fileDesc//tei:sourceDesc//tei:msDesc//tei:physDesc//tei:objectDesc
    
    

    let $tipo :=
        if (fn:empty($testimonianzaorale))
        
        then 
            (: --- controllo il tipo di fonte scritta --- :)
            
            (: lettera/lettere :)
            if ($tipologia_scritto/@form="letters") then
                
                let $lista_lettere:=$filexml//tei:TEI

                let $letters:=
                    <div class="intervista_container">
                        
                        <div class="trascrizione-legenda-container">
                            <!--trascrizione testo scritto-->
                            <div class="trascrizione">
                           
                            
                                { for $lettera in $lista_lettere
                                        let $titolo_lettera:=data($lettera//tei:fileDesc//tei:titleStmt//tei:title[@type="desc"])
                                        let $mittente:=$lettera//tei:correspAction[@type="sent"]//tei:persName
                                        let $destinatario:=$lettera//tei:correspAction[@type="received"]//tei:persName
                                        
                                        let $opener_dateline:=$lettera//tei:div[@type="messaggio"]//tei:opener/tei:dateline
                                        let $opener_salute:=$lettera//tei:div[@type="messaggio"]//tei:opener/tei:salute
                                        let $testo_lettera:=$lettera//tei:div[@type="messaggio"]//tei:ab
                                        let $closer:=$lettera//tei:div[@type="messaggio"]//tei:closer
                    
                                 
                                    return   
                                        <div>
                                            <div id="info_letter">
                                               <p><b>{data($titolo_lettera)}</b></p>
                                               <p><b>Mittente:</b>{$mittente}</p>
                                               <p><b>Destinatario:</b>{$destinatario}</p>
                                               <br/>
                                               
                                            </div>
                                            
                                            <div id="testo_letter">
                                                <p>{$opener_dateline}</p>
                                                <p>{$opener_salute}</p>
                                                <p>{$testo_lettera}</p>
                                                <p>{$closer}</p>
                                                <br/>
                                               <br/>
                                            </div>
                                        </div>
                                        
                                }     
                               
                            </div>
                            
                            <!--legenda scritto-->
                            <div class="divLegenda">
                                <div class="legenda">
                                    <h3>Fenomeni marcati</h3>
                                    <li id="gap" onclick="cambiaColoreGap()">Lacuna: <b>GAP XXX</b></li>
                                    <li id="del" onclick="cambiaColoreDel()">Cancellazione: <b>DEL</b></li> <!--aggiungere tipologie di del-->
                                    <li id="sic" onclick="cambiaColoreSic()">Parola errata: <b>SIC</b></li>
                                    <li id="corr" onclick="cambiaColoreCorr()">Parola corretta: <b>CORR</b></li>
                                    <li id="orig" onclick="cambiaColoreOrig()">Forma originale: <b>ORIG</b></li>
                                    <li id="reg" onclick="cambiaColoreReg()">Forma regolarizzata: <b>REG</b></li>
                                    <li id="abbr" onclick="cambiaColoreAbbr()">Abbreviazione: <b>ABBR</b></li>
                                    <li id="expan" onclick="cambiaColoreExpan()">Forma estesa: <b>EXPAN</b></li>
                                    <li id="emph" onclick="cambiaColoreEmph()">Parola enfatizzata: <b>EMPH</b></li>
                                    <li id="foreign" onclick="cambiaColoreForeign()">Parola in lingua straniera: <b>FOREIGN</b></li>
                                    <li id="distinct" onclick="cambiaColoreDistinct()">Parola arcaica: <b>DISTINCT</b></li>
                                    <li id="persName" onclick="cambiaColorePersName()">Antroponimo: <b>PERSNAME</b></li>
                                    <li id="placeName" onclick="cambiaColorePlaceName()">Luogo: <b>PLACENAME</b></li>
                                    <li id="orgName" onclick="cambiaColoreOrgName()">Organizzazione: <b>ORGNAME</b></li>
                                </div>
                                
                                <div id="buttonLegenda">
                                    <button class="buttonEventi" type="button" onclick="mostraEventi()">Mostra tutti i fenomeni</button>
                                </div>
                            </div>
                         </div>
                    </div>
                
                
                return $letters
            
            
                (: diario :)
                else if ($tipologia_scritto/@form="manuscript_diary") then
                    
                    let $front:=$filexml/tei:text/tei:front   (: primo <front> subito dento il primo <text> :)
                    
                    let $lista_pagine_diario_typePagina:=$filexml//tei:body//tei:div[@type="pagina"]  (: Ricci e Cimoli:)
                    let $lista_pagine_diario_typeGiorno:=$filexml//tei:body//tei:div[@type="giorno"]  (: Artom, Giuntini, Cimoli :)
                    
                    (: Cimoli ha <div type="Pagina"> e all'interno <div type="giorno"> :)

                    let $manuscript_diary:=
                        <div class="intervista_container">
                            
                            <div class="trascrizione-legenda-container">
                                <!--trascrizione testo scritto-->
                                <div class="trascrizione">
                                    
                                     {$front}
                                     <br/>
                                     <br/>
                                    
                                    
                                    {   
                                        if ($lista_pagine_diario_typePagina) then
                                            
                                            (: CASO DI CIMOLI :)
                                            if ($lista_pagine_diario_typeGiorno) then 
                                                for $giorno in $lista_pagine_diario_typeGiorno
                                                
                                                let $lista_ab:=$giorno//tei:ab
                                                
                                                for $ab in $lista_ab
                                                let $opener:=$giorno//tei:opener
                                                
                                                    return 
                                                            <div>
                                                                <div id="testo_pagina_diario">
                                                                    <p><b>{$opener}</b></p>
                                                                    <br/>
                                                                    <p>{$ab}</p>
                                                                    <br/>
                                                                </div>
                                                            </div>
                                                  
                                            else  (: CASO DI NICOLA RICCI :)
                                                 for $pagina in $lista_pagine_diario_typePagina
                                                    
                                                    let $lista_ab:=$pagina//tei:ab 
                                                    for $ab in $lista_ab
                                                        
                                                        return 
                                                            <div id="testo_pagina_diario">
                                                                <p>{$ab}</p>
                                                                <br/>
                                                            </div>
                                               

                                                        
                                                        
                                        (: CASO DI ARTOM E GIUNTINI :)             
                                        else if ($lista_pagine_diario_typeGiorno) then
                                            
                                            for $giorno in $lista_pagine_diario_typeGiorno
                                                (:  :let $lista_opener:=$lista_pagine_diario_typeGiorno//tei:opener
                                                for $opener in $lista_opener :)
                                                
                                                let $p:=$giorno/tei:p
                                                let $opener:=$giorno/tei:opener
                                               
                                                
                                                    return 
                                                            <div>
                                                                <div id="testo_pagina_diario">
                                                                    <p><b>{$opener}</b></p>
                                                                    <br/>
                                                                    <p>{$p}</p>
                                                                    <br/>
                                                                </div>
                                                            </div>
                                                            
 


                                               


                                         
                                        else ()   
                                    }     
                                   
                                </div>
                                
                                <!--legenda scritto-->
                                <div class="divLegenda">
                                    <div class="legenda">
                                        <h3>Fenomeni marcati</h3>
                                        <li id="gap" onclick="cambiaColoreGap()">Lacuna: <b>GAP XXX</b></li>
                                        <li id="del" onclick="cambiaColoreDel()">Cancellazione: <b>DEL</b></li> <!--aggiungere tipologie di del-->
                                        <li id="sic" onclick="cambiaColoreSic()">Parola errata: <b>SIC</b></li>
                                        <li id="corr" onclick="cambiaColoreCorr()">Parola corretta: <b>CORR</b></li>
                                        <li id="orig" onclick="cambiaColoreOrig()">Forma originale: <b>ORIG</b></li>
                                        <li id="reg" onclick="cambiaColoreReg()">Forma regolarizzata: <b>REG</b></li>
                                        <li id="abbr" onclick="cambiaColoreAbbr()">Abbreviazione: <b>ABBR</b></li>
                                        <li id="expan" onclick="cambiaColoreExpan()">Forma estesa: <b>EXPAN</b></li>
                                        <li id="emph" onclick="cambiaColoreEmph()">Parola enfatizzata: <b>EMPH</b></li>
                                        <li id="foreign" onclick="cambiaColoreForeign()">Parola in lingua straniera: <b>FOREIGN</b></li>
                                        <li id="distinct" onclick="cambiaColoreDistinct()">Parola arcaica: <b>DISTINCT</b></li>
                                        <li id="persName" onclick="cambiaColorePersName()">Antroponimo: <b>PERSNAME</b></li>
                                        <li id="placeName" onclick="cambiaColorePlaceName()">Luogo: <b>PLACENAME</b></li>
                                        <li id="orgName" onclick="cambiaColoreOrgName()">Organizzazione: <b>ORGNAME</b></li>
                                    </div>
                                    
                                    <div id="buttonLegenda">
                                        <button class="buttonEventi" type="button" onclick="mostraEventi()">Mostra tutti i fenomeni</button>
                                    </div>
                                </div>
                             </div>
                             
                             
                        </div>
                        
                    return $manuscript_diary
            
            
                (: foglio manoscritto :)
                else if ($tipologia_scritto/@form="manuscript_sheet") then
                    
                    let $trascrizione:=$filexml//tei:body//tei:div[@type="doc"]
                    let $ab:=$trascrizione//tei:ab
                    
                    let $manuscript_sheet:=
                        <div class="intervista_container">
                            
                            <div class="trascrizione-legenda-container">
                                <!--trascrizione testo scritto-->
                                <div class="trascrizione">
                                
                                    {
                                        
                                    <div>
                                        <div id="testo_pagina_diario">
                                            <p>{$ab}</p>
                                        </div>
                                    </div>
                                    }
                                        
                                   
                                </div>
                                
                                <!--legenda scritto-->
                                <div class="divLegenda">
                                    <div class="legenda">
                                        <h3>Fenomeni marcati</h3>
                                        <li id="gap" onclick="cambiaColoreGap()">Lacuna: <b>GAP XXX</b></li>
                                        <li id="del" onclick="cambiaColoreDel()">Cancellazione: <b>DEL</b></li> <!--aggiungere tipologie di del-->
                                        <li id="sic" onclick="cambiaColoreSic()">Parola errata: <b>SIC</b></li>
                                        <li id="corr" onclick="cambiaColoreCorr()">Parola corretta: <b>CORR</b></li>
                                        <li id="orig" onclick="cambiaColoreOrig()">Forma originale: <b>ORIG</b></li>
                                        <li id="reg" onclick="cambiaColoreReg()">Forma regolarizzata: <b>REG</b></li>
                                        <li id="abbr" onclick="cambiaColoreAbbr()">Abbreviazione: <b>ABBR</b></li>
                                        <li id="expan" onclick="cambiaColoreExpan()">Forma estesa: <b>EXPAN</b></li>
                                        <li id="emph" onclick="cambiaColoreEmph()">Parola enfatizzata: <b>EMPH</b></li>
                                        <li id="foreign" onclick="cambiaColoreForeign()">Parola in lingua straniera: <b>FOREIGN</b></li>
                                        <li id="distinct" onclick="cambiaColoreDistinct()">Parola arcaica: <b>DISTINCT</b></li>
                                        <li id="persName" onclick="cambiaColorePersName()">Antroponimo: <b>PERSNAME</b></li>
                                        <li id="placeName" onclick="cambiaColorePlaceName()">Luogo: <b>PLACENAME</b></li>
                                        <li id="orgName" onclick="cambiaColoreOrgName()">Organizzazione: <b>ORGNAME</b></li>
                                    </div>
                                    
                                    <div id="buttonLegenda">
                                        <button class="buttonEventi" type="button" onclick="mostraEventi()">Mostra tutti i fenomeni</button>
                                    </div>
                                </div>
                             </div>
                        </div>
                        
                    return $manuscript_sheet
                    
                    
                (: fascicolo :)
                else if ($tipologia_scritto/@form="dossier") then
                    
                    let $head:=$filexml//tei:body//tei:div[@type="page"]/tei:head
                    let $lista_p:=$filexml//tei:body//tei:div[@type="page"]/tei:p
                    

                    let $dossier:=
                        <div class="intervista_container">
                            
                            <div class="trascrizione-legenda-container">
                                <!--trascrizione testo scritto-->
                                <div class="trascrizione">
                                    
                                    <div>
                                        <div id="testo_pagina_diario">
                                            <p>{$head}</p>
                                            <br/>
                                            <p>{for $p in $lista_p
                                                return 
                                                    <div>
                                                        <p>{$p}</p>
                                                        <br/>
                                                    </div>
                                                }
                                                
                                            </p>
                                           
                                            
                                                
                                        </div>
                                    
                                    </div>
                                    
                                </div>
                                
                                <!--legenda scritto-->
                                <div class="divLegenda">
                                    <div class="legenda">
                                        <h3>Fenomeni marcati</h3>
                                        <li id="gap" onclick="cambiaColoreGap()">Lacuna:<b>GAP XXX</b></li>
                                         <li id="del" onclick="cambiaColoreDel()">Cancellazione: <b>DEL</b></li> <!--aggiungere tipologie di del-->
                                        <li id="sic" onclick="cambiaColoreSic()">Parola errata: <b>SIC</b></li>
                                        <li id="corr" onclick="cambiaColoreCorr()">Parola corretta: <b>CORR</b></li>
                                        <li id="orig" onclick="cambiaColoreOrig()">Forma originale: <b>ORIG</b></li>
                                        <li id="reg" onclick="cambiaColoreReg()">Forma regolarizzata: <b>REG</b></li>
                                        <li id="abbr" onclick="cambiaColoreAbbr()">Abbreviazione: <b>ABBR</b></li>
                                        <li id="expan" onclick="cambiaColoreExpan()">Forma estesa: <b>EXPAN</b></li>
                                        <li id="emph" onclick="cambiaColoreEmph()">Parola enfatizzata: <b>EMPH</b></li>
                                        <li id="foreign" onclick="cambiaColoreForeign()">Parola in lingua straniera: <b>FOREIGN</b></li>
                                        <li id="distinct" onclick="cambiaColoreDistinct()">Parola arcaica: <b>DISTINCT</b></li>
                                        <li id="persName" onclick="cambiaColorePersName()">Antroponimo: <b>PERSNAME</b></li>
                                        <li id="placeName" onclick="cambiaColorePlaceName()">Luogo: <b>PLACENAME</b></li>
                                        <li id="orgName" onclick="cambiaColoreOrgName()">Organizzazione: <b>ORGNAME</b></li>
                                    </div>
                                    
                                    <div id="buttonLegenda">
                                        <button class="buttonEventi" type="button" onclick="mostraEventi()">Mostra tutti i fenomeni</button>
                                    </div>
                                </div>
                             </div>
                             
                             
                        </div>
                        
                    return $dossier
            
            
                else ()
                
                
                
                
                
                
        else
            
            let $xsl := doc("/db/apps/voci_inferno/modules/orali.xsl") 
            return transform:transform($filexml, $xsl, ())
            
            (:  let $intervista :=
                <div class="intervista-container">
                
                    <!--lista dei parlanti-->
                    <div class="lista_parlanti">
                        <!--<p><b>Interlocutori presenti nella testimonianza: </b> {string-join(for $who in $lista_who return substring-after($who, "#"), ', ')}</p>-->
                        <p><b>Interlocutori presenti nella testimonianza: </b> {string-join($lista_who, '-')}</p>
                    </div>
                    
                    
                    <!--creo il player per ascoltare la testimonianza-->
                    { 
                        
                        let $testimone:=
                            for $xml in $xmlCollection/*
                            let $titolo := fn:normalize-space($xml//tei:title[@xml:id="titolotestimonianza"])
                            
                            let $find_testimone := $xml//tei:person[@role="testimone"]
                            let $nome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:forename)
                            let $cognome_testimone:=fn:normalize-space(string-join($find_testimone/tei:persName/tei:surname, " "))
                            let $testimone :=concat($nome_testimone," ",$cognome_testimone)
                            
                            where $titolo = $titolotestimonianza
                            return $testimone
                            
                        let $testimone_:= replace($testimone, "\s+", "_")
                        
                        return 
                            
                            
                            <div id="traccia_audio" style="text-align:center; margin-top:3%;">
                               <audio controls="controls"> <!--class="audio_player" -->
                                    <source src="{concat("https://48001.omega.ilc.cnr.it/exist/rest/apps/voci_inferno/resources/audio/",$testimone_,".mp3")}"/>
                                </audio>
                            </div>
                        }
                    
                    
                    <!--<div id="traccia_audio" style="text-align:center; margin-top:3%;">
                        <audio class="audio_player" controls="controls">
                            <source src="http://127.0.0.1:5500/Sami_Modiano_2018.mp3" type="audio/mpeg"></source>
                        </audio>
                    </div>-->
 
                    <div class="trascrizione-legenda-container">
                        
                        <!--trascrizione orale-->
                        <div class="trascrizione">
                            {
                                for $u in $lista_u
                                let $who := substring-after(data($u/@who), "#")
                                return
                                    <div>
                                        <div id="u">
                                            
                                            <p><b>{$who}</b>: {
                                                for $child in $u/node()
                                                return
                                                    $child
                                            }</p>
                                            
                                        </div>
                                    </div>
                            }
                        </div>
                        
                        
                        
                        <!--legenda orale-->
                        <div class="divLegenda">
                            <div class="legenda">
                                <h3>Fenomeni marcati</h3>
                                <li id="gap" onclick="cambiaColoreGap()">Buco nella registrazione: <b>GAP XXX</b></li>
                                <li id="unclear" onclick="cambiaColoreUnclear()">Parola non chiara: <b>UNCLEAR</b></li>
                                <li id="pause" onclick="cambiaColorePause()">Pausa: <b>PAUSE (...)</b></li>
                                <li id="vocal" onclick="cambiaColoreVocal()">Esclamazione: <b>VOCAL</b></li>
                                <li id="incident" onclick="cambiaColoreIncident()">Rumore accidentale: <b>INCIDENT</b></li>
                                <li id="kinesic" onclick="cambiaColoreKinesic()">Movimento: <b>KINESIC</b></li>
                                <li id="del" onclick="cambiaColoreDel()">Frase o parola riformulata/ripetuta: <b>DEL</b></li> <!--aggiungere tipologie di del-->
                                <li id="sic" onclick="cambiaColoreSic()">Parola errata: <b>SIC</b></li>
                                <li id="corr" onclick="cambiaColoreCorr()">Parola corretta: <b>CORR</b></li>
                                <li id="orig" onclick="cambiaColoreOrig()">Forma dialettale: <b>ORIG</b></li>
                                <li id="reg" onclick="cambiaColoreReg()">Forma regolarizzata: <b>REG</b></li>
                                <li id="abbr" onclick="cambiaColoreAbbr()">Abbreviazione: <b>ABBR</b></li>
                                <li id="expan" onclick="cambiaColoreExpan()">Forma estesa: <b>EXPAN</b></li>
                                <li id="emph" onclick="cambiaColoreEmph()">Parola enfatizzata: <b>EMPH</b></li>
                                <li id="foreign" onclick="cambiaColoreForeign()">Parola in lingua straniera: <b>FOREIGN</b></li>
                                <li id="persName" onclick="cambiaColorePersName()">Antroponimo: <b>PERSNAME</b></li>
                                <li id="placeName" onclick="cambiaColorePlaceName()">Luogo: <b>PLACENAME</b></li>
                                <li id="orgName" onclick="cambiaColoreOrgName()">Organizzazione: <b>ORGNAME</b></li>
                            </div>
                            
                            
                            
                            <div id="buttonLegenda">
                                <button class="buttonEventi" type="button" onclick="mostraEventi()">Mostra tutti i fenomeni</button>
                            </div>
                        </div>
                    </div>
                </div>
                    
               
                
            return $intervista :)
        
                 
     return $tipo
     
     
};

declare function app:play-audio($node as node(), $model as map(*)){
    
    
    let $titolotestimonianza :=request:get-parameter("titolotestimonianza","")
    let $xmlCollection:=collection("/db/apps/voci_inferno/xml")
    
    let $testimone:=
        for $xml in $xmlCollection/*
        let $titolo := fn:normalize-space($xml//tei:title[@xml:id="titolotestimonianza"])
        
        let $find_testimone := $xml//tei:person[@role="testimone"]
        let $nome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:forename)
        let $cognome_testimone:=fn:normalize-space(string-join($find_testimone/tei:persName/tei:surname, " "))
        let $testimone :=concat($nome_testimone," ",$cognome_testimone)
        
        where $titolo = $titolotestimonianza
        return $testimone
        
    let $testimone_:= replace($testimone, "\s+", "_")
    

    return 
        
        
        <div id="traccia_audio" style="text-align:center; margin-top:3%;">
           <audio class="audio_player" controls="controls">
                <source src="{concat("https://48001.omega.ilc.cnr.it/exist/rest/apps/voci_inferno/resources/audio/",$testimone_,".mp3")}"/>
            </audio>
        </div>
        

};

(:  declare function local:tabelle(){
    let $titolotestimonianza :=request:get-parameter("titolotestimonianza","")
    
    let $xmlCollection:=collection("/db/apps/voci_inferno/xml")
    let $filexml := 
        for $xml in $xmlCollection/*
        let $titolo := fn:normalize-space($xml//tei:title[@xml:id="titolotestimonianza"])
        where $titolo = $titolotestimonianza
        return $xml
    let $lista_persone := $filexml//tei:listPerson//tei:person 
    let $lista_luoghi := $filexml//tei:listPlace//tei:place
    let $lista_org := $filexml//tei:listOrg//tei:org
    let $text:=$filexml/tei:text
    return
        json:serialize(
    [
      for $person in $lista_persone
      let $x := data($person/@xml:id)
      let $occorrenze := count($text//tei:persName[@ref = concat("#", $x)])
      order by $occorrenze descending
      return
        {
          "id": data($person/@xml:id),
          "occorrenze": $occorrenze,
          "persName": string($person/tei:persName),
          "note": if ($person/tei:note) then string($person/tei:note) else "/",
          "sex": string($person/tei:sex),
          "birth": 
            if ($person/tei:birth/tei:date and $person/tei:birth/tei:placeName) 
            then concat(string($person/tei:birth/tei:date), " (", normalize-space($person/tei:birth/tei:placeName), ")")
            else if ($person/tei:birth/tei:date) 
            then string($person/tei:birth/tei:date)
            else if ($person/tei:birth/tei:placeName) 
            then normalize-space($person/tei:birth/tei:placeName)
            else "/",
          "death":
            if ($person/tei:death/tei:date and $person/tei:death/tei:placeName) 
            then concat(string($person/tei:death/tei:date), " (", normalize-space($person/tei:death/tei:placeName), ")")
            else if ($person/tei:death/tei:date) 
            then string($person/tei:death/tei:date)
            else if ($person/tei:death/tei:placeName) 
            then normalize-space($person/tei:death/tei:placeName)
            else "/",
          "source": if ($person/@source) then string($person/@source) else ""
        }
    ]
  )
    
    };:)

declare function app:statistiche_testimonianza($node as node(), $model as map(*)){
    let $titolotestimonianza :=request:get-parameter("titolotestimonianza","")
    
    let $xmlCollection:=collection("/db/apps/voci_inferno/xml")
    let $filexml := 
        for $xml in $xmlCollection/*
        let $titolo := fn:normalize-space($xml//tei:title[@xml:id="titolotestimonianza"])
        where $titolo = $titolotestimonianza
        return $xml

    let $testimone := concat($filexml//tei:person[@role="testimone"]//tei:persName//tei:forename," ",$filexml//tei:person[@role="testimone"]//tei:persName//tei:surname[1])
    let $testimonianzaorale:=$filexml//tei:sourceDesc/tei:recordingStmt    (: orale o scritta :)
    
    
    let $tipo:=if (fn:empty($testimonianzaorale))  (: se la testimonianza è SCRITTA :)
        then
            let $statistiche_scritto:=
                        let $gap:=count($filexml//tei:text//tei:gap)
                        let $del:=count($filexml//tei:text//tei:del)
                        let $add:=count($filexml//tei:text//tei:add)
                        
                        let $sic:=count($filexml//tei:text//tei:sic)
                        let $orig:=count($filexml//tei:text//tei:orig)
                        let $abbr:=count($filexml//tei:text//tei:abbr)
                        let $emph:=count($filexml//tei:text//tei:emph)
                        let $foreign:=count($filexml//tei:text//tei:foreign)
                        let $distinct:=count($filexml//tei:text//tei:distinct[@type="archaic"])
                        
                        let $persName:=count($filexml//tei:text//tei:persName)
                        let $placeName:=count($filexml//tei:text//tei:placeName)
                        let $orgName:=count($filexml//tei:text//tei:orgName)
                        
                        
                        (: CHIARA :)
                        let $person:=count($filexml//tei:listPerson//tei:person)
                        let $place:=count($filexml//tei:listPlace//tei:place)
                        let $org:=count($filexml//tei:listOrg//tei:org)
                
                
                        let $lista_persone := $filexml//tei:listPerson//tei:person 
                        let $lista_luoghi := $filexml//tei:listPlace//tei:place
                        let $lista_org := $filexml//tei:listOrg//tei:org
                        
                        let $lista_bibl_sec := $filexml//tei:standOff//tei:listBibl//(tei:bibl|tei:biblStruct)
                        let $text:=$filexml//tei:text
                
            
                        
                        return 
                            
                            <div>
                                <head>
                                    
                                    <!--<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.min.js"></script>--> <!--versione di chart.js -->
                                    
                                    <script src="https://npmcdn.com/chart.js@latest/dist/chart.umd.js"></script> <!--regola dimensione-->
                                    
                                    <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2.2.0"></script> <!--plugins-->
                                    
                                    <script src="http://code.jquery.com/jquery-latest.min.js"></script>
                                    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.2/dist/chart.umd.js"></script>
                                    <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2"></script>
                                    
                                    <script src="https://code.highcharts.com/highcharts.js"></script>
                                    <script src="https://code.highcharts.com/modules/treemap.js"></script>
                                    <script src="https://code.highcharts.com/modules/treegraph.js"></script>
                                    <script src="https://code.highcharts.com/modules/exporting.js"></script>
                                    <script src="https://code.highcharts.com/modules/accessibility.js"></script>
                                    <script src="https://code.highcharts.com/modules/timeline.js"></script>
                                
                                    
                                </head>
                                
                                 <p style="text-align:justify;margin-top:20px;padding-left:50px;padding-right:50px;"> In questa sezione sono analizzati alcuni fenomeni incontrati e opportunamente marcati durante la fase di codifica della testimonianza. Il primo grafico mette in evidenza alcune pratiche editoriali individuate e segnalate, come lacune, cancellazioni e aggiunte. Il secondo pone l'attenzione sul modo di esprimersi del testimone, riportando infatti statistiche riguardanti ad esempio le parole che sono state normalizzate, ovvero riportate nell'italiano standard dal reponsabile della codifica, le parole che il testimone scrive in forma abbreviata, o le parole arcaiche e straniere che vengono utilizzate. Il terzo grafico mostra invece la ripartizione, all'interno della testimonianza, delle entità nominate, quindi persone, luoghi e organizzazioni, che sono state citate. Per un maggiore approfondimento, per ciascuna entità è presente una tabella, ordinata in maniera decrescente per numero di occorrenze, che mostra quali sono le persone, i luoghi e le organizzazioni menzionate e quante volte ricorrono nel testo.
                                </p>
                                    
                                
                                
                                <h2 style="text-align:center;margin-top:80px;padding-left:50px;padding-right:50px;">Fenomeni presenti nella testimonianza di <em>{$testimone}</em> </h2>
                                <p style="text-align:center;margin-top:25px;padding-left:50px;padding-right:50px;">Il grafico riporta alcune statistiche che mettono in evidenza le seguenti pratiche editoriali: le lacune (gap), le cancellazioni (del) e le aggiunte (add) presenti nel testo della testimonianza.</p>
                                
                                <div class="statistiche">
                                   
                                       
                                        <div id="grafico_fenomeni">
                                            <!--<canvas id="fenomeni_scritto" ></canvas>-->
                                            
                                            <figure class="highcharts-figure">
                                            <div id="container">
                                                
                                               <script>
                                        
                                                    Highcharts.chart('container', {{
                                                        chart: {{
                                                            plotBackgroundColor: null,
                                                            plotBorderWidth: null,
                                                            plotShadow: false,
                                                            type: 'pie'
                                                        }},
                                                        title: {{
                                                            text: null,
                                                            
                                                        }},
                                                        
                                                        
                                                        
                                                        
                                                        tooltip: {{
                                                            pointFormat: '{{series.name}}: <b>{{point.y}}</b>'
                                                        }},
                                                        accessibility: {{
                                                            point: {{
                                                                valueSuffix: ''
                                                            }}
                                                        }},
                                                        plotOptions: {{
                                                            pie: {{
                                                                allowPointSelect: true,
                                                                cursor: 'pointer',
                                                                dataLabels: {{
                                                                    enabled: true,
                                                                    style: {{
                                                                                fontSize: '12px', // Dimensione del font delle etichette sui dati
                                                                                
                                                                            }},
                                                                    format: '<span style="font-size: 1.2em"><b>{{point.name}}</b>' +
                                                                            '</span> ' +
                                                                            '<span style="opacity: 0.6">{{point.percentage:.1f}} ' +
                                                                            '%</span>',
                                                                    connectorColor: 'rgba(128,128,128,0.5)'
                                                                }}
                                                            }}
                                                        }},
                                                        series: [{{
                                                            name: 'Occorrenze',
                                                            data: [
                                                                {{name: 'Lacune', y: {$gap}, color:'#b91d47'}},
                                                                {{name: 'Cancellazioni', y: {$del}, color:'#00aba9'}},
                                                                {{name: 'Aggiunte', y: {$add}, color:'#2b5797'}},
                                                            ]
                                                        }}]
                                                    }});
                                        
                                        
                                            
                                                </script> 
                                                
                                                    
                                                
                                                
                                            </div>
                                            </figure>
                                        </div>
                                        
                                    
                                        
                                        
                                    
                                </div>
                                
                                
                                <h2 style="text-align:center;margin-top:80px;">Come scrive <em>{$testimone}</em></h2>
                                <p style="text-align:center;margin-top:25px;padding-left:50px;padding-right:50px;">Il grafico mostra la quantità di errori di scrittura del testimone, le parole normalizzate, ovvero riportate nell'italiano standard dal reponsabile della codifica, le parole abbreviate, le parole enfatizzate, cioè sottolineate per effetto linguistico o retorico, le parole in lingua diversa rispetto alla lingua principale del testo e le parole arcaiche. Tutti questi fenomeni sono stati riportati nello stesso grafico per analizzare il modo in cui il testimone si esprime.</p>

                                <div class="statistiche">

                                        <div id="grafico_fenomeni1">
                                            <!--<canvas id="parole_scritto"></canvas>-->
                                              <figure class="highcharts-figure">
                                                <div id="container7">
                                                                                        
                                            
                                            
                                                    <script>
                                                        
                                                        Highcharts.chart('container7', {{
                                                            chart: {{
                                                                type: 'bar' // Imposta il tipo di grafico come 'bar' come specificato
                                                            }},
                                                            title: {{
                                                                text: null
                                                            }},
                                                            xAxis: {{
                                                                categories: [
                                                                    'Parole errate', 
                                                                    'Parole normalizzate', 
                                                                    'Abbreviazioni', 
                                                                    'Parole enfatizzate', 
                                                                    'Parole in lingua straniera', 
                                                                    'Parole arcaiche', 
                                                                ],
                                                                title: {{
                                                                    text: null
                                                                }},
                                                                labels:{{
                                                                    style:{{
                                                                        fontSize:'12px;'
                                                                    }}
                                                                }},
                                                            }},
                                                            yAxis: {{
                                                                min: 0,
                                                                title: {{
                                                                    text: null
                                                                }}
                                                            }},
                                                            tooltip: {{
                                                                valueSuffix: ' '
                                                            }},
                                                            plotOptions: {{
                                                                bar: {{
                                                                    dataLabels: {{
                                                                        enabled: true,
                                                                        style:{{
                                                                           fontSize:'12px;',
                                                                          
                                                                            
                                                                        }},
                                                                        formatter: function() {{
                                                                            let sum = this.series.data.reduce((acc, point) => acc + point.y, 0);
                                                                            let percentage = Math.round((this.y / sum) * 100) + '%';
                                                                            return `${{percentage}} (${{this.y}})`; // Mostra sia la percentuale che il valore assoluto
                                                                        }}
                                                                    }},
                                                                    
                                                                     pointWidth: 30
                                                                }}
                                                            }},
                                                            series: [{{
                                                                name: 'Occorrenze',
                                                                color: 'black',
                                                                data: [
                                                                    {{ y: {$sic}, color: '#b91d47' }},  
                                                                    {{ y: {$orig}, color: '#00aba9' }},    
                                                                    {{ y: {$abbr}, color: '#2b5797' }},    
                                                                    {{ y: {$emph}, color: '#e8c3b9' }},     
                                                                    {{ y: {$foreign}, color: '#1e7145' }},              
                                                                    {{ y: {$distinct}, color: '#8c53e0' }},               
                                                                    
                                                                ]
                                                            }}],
                                                            credits: {{
                                                                enabled: false
                                                            }}
                                                        }});
        
                                                    </script>
                                                </div>
                                            </figure>
                                        </div>
                                        
                                        
                                    
                                </div>
                                
                                
                                <h2 style="text-align:center;margin-top:80px;">Entità nominate nella testimonianza di <em>{$testimone}</em></h2>
                                <p style="text-align:center;margin-top:25px;padding-left:50px;padding-right:50px;">Il grafico a sinistra mostra le entità nominate citate nel testo, quindi quante persone, quanti luoghi e quante organizzazioni compaiono. Il grafico a destra mostra invece quanti nomi vengono citati.</p>
                                
                                <div class="statistiche">
                                        
                                        <!--CHIARA -->
                                         <div id="grafico_fenomeni1" style="margin-top:50px;">
                                            <!--<canvas id="grafico_entita_scritto"></canvas>-->
                                            
                                            
                                            
                                            <figure class="highcharts-figure">
                                                <div id="container5">
                                                    
                                                    <script>
                                                        Highcharts.chart('container5', {{
                                                                chart: {{
                                                                    type: 'column'
                                                                }},
                                                                title: {{
                                                                    text: null
                                                                }},
                                                               
                                                                xAxis: {{
                                                                    categories: ['Persone', 'Luoghi', 'Organizzazioni'],
                                                                    crosshair: true,
                                                                    accessibility: {{
                                                                        description: 'Entità nominate'
                                                                    }}
                                                                }},
                                                                yAxis: {{
                                                                    min: 0,
                                                                    title: {{
                                                                        text: ''
                                                                    }}
                                                                }},
                                                                tooltip: {{
                                                                    valueSuffix: ''
                                                                }},
                                                                plotOptions: {{
                                                                    column: {{
                                                                        pointPadding: 0.2,
                                                                        borderWidth: 0
                                                                    }}
                                                                }},
                                                                series: [
                                                                    {{
                                                                        name: 'Totale entità presenti nella testimonianza',
                                                                        data: [{$person}, {$place}, {$org}],
                                                                        color: '#2b5797'
                                                                    }},
                                                                    {{
                                                                        name: 'Numero di occorrenze nella testimonianza',
                                                                        data: [{$persName}, {$placeName}, {$orgName}],
                                                                        color: '#b91d47'
                                                                    }}
                                                                ]
                                                            }});
                                                        </script>
                                                </div>
                                            
                                            
                                            </figure>
                                            
                                            
                                            
                                            
                                        </div>
                                        
                                        
                                        
                                        
                                </div>
                                        
                                        
                                
                                <h2 style="text-align:center;margin-top:80px;margin-bottom:80px;" >Le seguenti tabelle riportano l'elenco delle persone, dei luoghi e delle organizzazioni che sono state citate dal testimone, ordinando i risultati in base al numero di occorrenze.</h2>
                                <div>
                                   
                                        <h2 style="text-align:center;margin-bottom:25px; padding-left:50px;padding-right:50px;"><em>Quali persone e quante volte vengono citate nella testimonianza?</em></h2>
                                        <div id="tabella_persone" class="section_tabella">
                                        
                                            
                                            <table class="tabella">
                                              <tr>
                                                <th>ID</th>
                                                <th>Occorrenze</th>
                                                <th>Nome</th>
                                                <th>Note</th>
                                                <th>Sesso</th>
                                                <th>Nascita</th>
                                                <th>Morte</th>
                                                <th>Link</th>
                                              </tr>
                                              {
                                                  
                                                for $person in $lista_persone
                                                    let $x:=data($person/@xml:id)
                                                    let $occorrenze:=count($text//tei:persName[@ref=concat("#",$x)])
                                                    order by $occorrenze descending
                                                return
                                                <tr>
                                                  <td>{data($person/@xml:id)}</td>
                                                  <td>{$occorrenze}</td>
                                                  <td>{$person/tei:persName}</td>
                                                  <td>{if ($person/tei:note) then ($person/tei:note) else "/"}</td>
                                                  <td>{$person/tei:sex}</td>
                                                  <td>{if ($person/tei:birth/tei:date and $person/tei:birth/tei:placeName) then concat($person/tei:birth/tei:date, " (", fn:normalize-space($person/tei:birth/tei:placeName), ")")
                                                        else if ($person/tei:birth/tei:date) then $person/tei:birth/tei:date
                                                        else if ($person/tei:birth/tei:placeName) then fn:normalize-space($person/tei:birth/tei:placeName) else "/"}</td>
                                                  <td>{if ($person/tei:death/tei:date and $person/tei:death/tei:placeName) then concat($person/tei:death/tei:date, " (", fn:normalize-space($person/tei:death/tei:placeName), ")")
                                                        else if ($person/tei:death/tei:date) then $person/tei:death/tei:date
                                                        else if ($person/tei:death/tei:placeName) then fn:normalize-space($person/tei:death/tei:placeName) else "/"}</td>
                                                   <td>{if ($person/@source) then <a href="{data($person/@source)}" target="blank">Scopri di più</a>
                                                        else " "}</td>
                                                </tr>
                                              }
                                            </table>
                                            
                                        </div>
                                        
                                        
                                        
                                        <h2 style="text-align:center;margin-bottom:25px; padding-left:50px;padding-right:50px;"><em>Quali luoghi e quante volte vengono citati nella testimonianza?</em></h2>
                                        <div id="tabella_luoghi" class="section_tabella">
                                        
                                            <table class="tabella"> 
                                                  <tr>
                                                    <th>ID</th>
                                                    <th>Occorrenze</th>
                                                    <th>Nome</th>
                                                    <th>Provincia/Regione</th>
                                                    <th>Stato</th>
                                                    <th>Link</th>
                                                  </tr>
                                                  {
                                                      
                                                    for $place in $lista_luoghi
                                                        let $x:=data($place/@xml:id)
                                                        let $occorrenze:=count($text//tei:placeName[@ref=concat("#",$x)])
                                                        order by $occorrenze descending
                                                    return
                                                    <tr>
                                                      <td>{data($place/@xml:id)}</td>
                                                      <td>{$occorrenze}</td>
                                                      <td>{$place/tei:placeName}</td>
                                                      <td>{
                                                          if ($place/tei:settlement[@type="province"] and $place/tei:settlement[@type="region"]) then
                                                            concat(
                                                                string-join($place/tei:settlement[@type="province"], ", "), ", ", string-join($place/tei:settlement[@type="region"], ", "))
                                                          else if ($place/tei:settlement[@type="province"]) then
                                                            string-join($place/tei:settlement[@type="province"], " ")
                                                          else if ($place/tei:settlement[@type="region"]) then
                                                            string-join($place/tei:settlement[@type="region"], " ")
                                                          else
                                                            "/"
                                                        }
                                                      </td>
                                                      <td>{string-join($place/tei:country, ", ")}</td>
                                                      <td>{if ($place/@source) then <a href="{data($place/@source)}" target="blank">Scopri di più</a>
                                                            else " "}</td>
                                                    </tr>
                                                  }
                                                </table>
                                        
                                            </div>
                                        
                                        

                                            <h2 style="text-align:center;margin-bottom:25px; padding-left:50px;padding-right:50px;"><em>Quali organizzazioni e quante volte vengono citate nella testimonianza?</em></h2>
                                            <div id="tabella_organizzazioni" class="section_tabella">
                                            
                                                <table class="tabella">
                                                      <tr>
                                                        <th>ID</th>
                                                        <th>Occorrenze</th>
                                                        <th>Nome</th>
                                                        <th>Sede</th>
                                                        <th>Descrizione</th>
                                                        <th>Link</th>
                                                      </tr>
                                                      {
                                                          
                                                        for $org in $lista_org
                                                            let $x:=data($org/@xml:id)
                                                            let $occorrenze:=count($text//tei:orgName[@ref=concat("#",$x)])
                                                            order by $occorrenze descending
                                                        return
                                                        <tr>
                                                          <td>{data($org/@xml:id)}</td>
                                                          <td>{$occorrenze}</td>
                                                          <td>{$org/tei:orgName}</td>
                                                          <td>{$org/tei:placeName}</td>
                                                          <td>{$org/tei:desc}</td>
                                                          <td>{if ($org/@source) then <a href="{data($org/@source)}" target="blank">Scopri di più</a>
                                                                else " "}</td>
                                                        </tr>
                                                      }
                                                </table>
                                            </div>
                                            
                                        
                                         
                                         <!--tabella biblioteca-->
                                         
                                         <h2 style="text-align:center; margin-bottom:25px; padding-left:50px; padding-right:50px;"><em>La biblioteca di {$testimone}</em></h2>
                                        <div id="tabella_biblioteca" class="section_tabella">
                                        
                                        <table class="tabella"> 
                                              <tr>
                                                <th>ID</th>
                                                <th>Occorrenze</th>
                                                <th>Autore</th>
                                                <th>Titolo</th>
                                                <th>Luogo di pubblicazione</th>
                                                <th>Editore</th>
                                                <th>Data</th>
                                              </tr>
                                              {
                                                  
                                               for $bibl in $lista_bibl_sec
                                                    let $x:=data($bibl/@xml:id)
                                                    let $occorrenze := count(
                                                        $text//(
                                                          tei:title[@ref=concat("#", $x)] |
                                                          tei:ref[@target=concat("#", $x)]
                                                        )
                                                      )
                                                    order by $occorrenze descending
                                                return
                                                <tr>
                                                    <td>{data($bibl/@xml:id)}</td>
                                                    <td>{$occorrenze}</td>
                                                    <td>{$bibl//tei:author}</td>
                                                   
                                                    <td>{data($bibl//tei:title)}</td>
                                                    
                                                    <td>{if (empty($bibl/tei:pubPlace)) then
                                                                "/"
                                                             else
                                                                $bibl/tei:pubPlace}
                                                        </td>
                                                      <td>{if (empty($bibl/tei:publisher)) then
                                                                "/"
                                                             else
                                                                $bibl/tei:publisher}
                                                        </td>
                                                      <td>{if ($bibl instance of element(tei:bibl)) then
                                                                $bibl/tei:date
                                                              else
                                                                $bibl/tei:monogr/tei:imprint/tei:date}
                                                    </td>  
                                                    
                                                
                                                    <!--CODICE DI CHIARA-->
                                                    
                                                    <!--<td>{data($bibl/@xml:id)}</td>
                                                    <td>{$occorrenze}</td>
                                                    <td>{if ($bibl instance of element(tei:bibl)) then
                                                                $bibl/tei:author
                                                            else
                                                                $bibl/tei:monogr/tei:author}
                                                      </td>
                                                    <td>{
                                                              if ($bibl instance of element(tei:bibl)) then
                                                                string($bibl//tei:title)
                                                              else
                                                                let $titles := (
                                                                  $bibl/tei:series/tei:title,
                                                                  $bibl/tei:monogr/tei:title,
                                                                  $bibl/tei:analytic/tei:title
                                                                )
                                                                return string-join($titles, ",")
                                                            }
                                                      </td>
                                                      <td>{if (empty($bibl/tei:pubPlace)) then
                                                                "/"
                                                             else
                                                                $bibl/tei:pubPlace}
                                                        </td>
                                                      <td>{if (empty($bibl/tei:publisher)) then
                                                                "/"
                                                             else
                                                                $bibl/tei:publisher}
                                                        </td>
                                                      <td>{if ($bibl instance of element(tei:bibl)) then
                                                                $bibl/tei:date
                                                              else
                                                                $bibl/tei:monogr/tei:imprint/tei:date}
                                                      </td> -->
                                                    
                                                </tr>
                                              }
                                            </table>
                                        
                                        </div>
                                         
                                         
                                         
                                                       
        
                                            
                                        
                                    </div>
                                    
                                    
                                    
                            </div>
                            
                            
                            
                                    
                        
            return $statistiche_scritto
            
        
        
        
        
        
        else (: se la testimonianza è ORALE :)
            let $statistiche_orale:=
                        let $gap:=count($filexml//tei:body//tei:u//tei:gap)
                        let $unclear:=count($filexml//tei:body//tei:u//tei:unclear)
                        let $pause:=count($filexml//tei:body//tei:u//tei:pause)
                        let $vocal:=count($filexml//tei:body//tei:u//tei:vocal)
                        let $incident:=count($filexml//tei:body//tei:u//tei:incident)
                        let $kinesic:=count($filexml//tei:body//tei:u//tei:kinesic)
                        let $del_reformulation:=count($filexml//tei:body//tei:u//tei:del[@type="reformulation"])
                        let $del_correction:=count($filexml//tei:body//tei:u//tei:del[@type="correction"])
                        let $del_truncation:=count($filexml//tei:body//tei:u//tei:del[@type="truncation"])
                        let $del_repetition:=count($filexml//tei:body//tei:u//tei:del[@type="repetition"])
                        let $sic:=count($filexml//tei:body//tei:u//tei:sic)
                        let $orig:=count($filexml//tei:body//tei:u//tei:orig)
                        let $abbr:=count($filexml//tei:body//tei:u//tei:abbr)
                        let $emph:=count($filexml//tei:body//tei:u//tei:emph)
                        let $foreign:=count($filexml//tei:body//tei:u//tei:foreign)
                        
                        let $persName:=count($filexml//tei:text//tei:u//tei:persName)
                        let $placeName:=count($filexml//tei:text//tei:u//tei:placeName)
                        let $orgName:=count($filexml//tei:text//tei:orgName)
                        
                        
                        
                         (: variabili per popolare tabelle :)
                         
                         (: elementi presenti nello standOff :)
                        let $person:=count($filexml//tei:standOff//tei:listPerson//tei:person)
                        let $place:=count($filexml//tei:standOff//tei:listPlace//tei:place)
                        let $org:=count($filexml//tei:standOff//tei:listOrg//tei:org)
                
                
                        let $lista_persone := $filexml//tei:standOff/tei:listPerson//tei:person 
                        let $lista_luoghi := $filexml//tei:standOff/tei:listPlace//tei:place
                        let $lista_org := $filexml//tei:standOff//tei:listOrg//tei:org
                        
                        let $lista_bibl_sec := $filexml//tei:standOff//tei:listBibl//(tei:bibl|tei:biblStruct)
                        let $text:=$filexml//tei:text
                        
                        
                        (: lista relazioni :)
                         let $lista_relazioni := $filexml//tei:standOff/tei:listRelation//tei:relation
                         
                
                        return 
                            
                            
                            <div>
                                <head>
                                    
                                    <!--<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.min.js"></script>--> <!--versione di chart.js -->
                                    
                                    <script src="https://npmcdn.com/chart.js@latest/dist/chart.umd.js"></script> <!--regola dimensione-->
                                    
                                    <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2.2.0"></script> <!--plugins-->
                                    <script src="https://code.highcharts.com/highcharts.js"></script>
                                    <script src="https://code.highcharts.com/modules/treemap.js"></script>
                                    <script src="https://code.highcharts.com/modules/treegraph.js"></script>                                    
                                    <script src="https://code.highcharts.com/maps/highmaps.js"></script>
                                    <script src="https://code.highcharts.com/modules/exporting.js"></script>
                                    <script src="https://code.highcharts.com/modules/accessibility.js"></script>
                                    <script src="https://code.highcharts.com/modules/networkgraph.js"></script>
                                    <script src="https://code.highcharts.com/modules/timeline.js"></script>
                                            
                                    
                                </head>
                                
                                 <p style="text-align:justify;margin-top:20px;padding-left:50px;padding-right:50px;"> In questa sezione sono analizzati alcuni fenomeni incontrati e opportunamente marcati durante la fase di codifica della testimonianza. Il primo grafico mette in evidenza alcuni fenomeni che caratterizzano una fonte orale, come eventuali lacune dal punto di vista uditivo presenti nella testimonianza. Il secondo pone l'attenzione sul modo di esprimersi del testimone, riportando infatti statistiche riguardanti ad esempio le parole o le frasi riformulate, ripetute o interrotte durante l'enunciato, le parole espresse in forma dialettale o le parole enfatizzate, e dunque pronunciate con un'enfasi diversa. Il terzo grafico mostra invece la ripartizione, all'interno della testimonianza, delle entità nominate, quindi persone, luoghi e organizzazioni, che sono state citate. Per un maggiore approfondimento, per ciascuna entità è presente una tabella, ordinata in maniera decrescente per numero di occorrenze, che mostra quali sono le persone, i luoghi e le organizzazioni menzionate e quante volte ricorrono nella testimonianza.
                                </p>
                                
                                
                                <h2 style="text-align:center;margin-top:80px;">Fenomeni presenti nella testimonianza di <em>{$testimone}</em> </h2>
                                <p style="text-align:center;margin-top:25px;padding-left:50px;padding-right:50px;">Il grafico riporta alcune statistiche che mettono in evidenza i fenomeni che caratterizzano una fonte orale: i buchi presenti all'interno della registrazione, i passaggi poco chiari perchè non udibili con certezza, le pause tra un enunciato e l'altro, le esclamazioni, i rumori accidentali che interferiscono nell'audio della registrazione e i movimenti in caso di testimonianze in formato video. </p>
                                <div class="statistiche">
                                        
                                       
                                    
                                        
                                     <div id="grafico_fenomeni">
                                            <!--<canvas id="fenomeni_orale" ></canvas>-->
                                            
                                            <figure class="highcharts-figure">
                                                    <div id="container">
                                                        
                                                       <script>
                                                
                                                            Highcharts.chart('container', {{
                                                                chart: {{
                                                                    plotBackgroundColor: null,
                                                                    plotBorderWidth: null,
                                                                    plotShadow: false,
                                                                    type: 'pie'
                                                                }},
                                                                title: {{
                                                                    text: null,
                                                                    
                                                                }},

                                                                tooltip: {{
                                                                    pointFormat: '{{series.name}}: <b>{{point.y}}</b>'
                                                                }},
                                                                accessibility: {{
                                                                    point: {{
                                                                        valueSuffix: ''
                                                                    }}
                                                                }},
                                                                plotOptions: {{
                                                                    pie: {{
                                                                        allowPointSelect: true,
                                                                        cursor: 'pointer',
                                                                        dataLabels: {{
                                                                            enabled: true,
                                                                            style: {{
                                                                                fontSize: '12px', // Dimensione del font delle etichette sui dati
                                                                                
                                                                            }},
                                                                            format: '<span style="font-size: 1.2em"><b>{{point.name}}</b>' +
                                                                                    '</span> ' +
                                                                                    '<span style="opacity: 0.6">{{point.percentage:.1f}} ' +
                                                                                    '%</span>',
                                                                            connectorColor: 'rgba(128,128,128,0.5)'
                                                                        }}
                                                                    }}
                                                                }},
                                                                series: [{{
                                                                    name: 'Occorrenze',
                                                                    data: [
                                                                        {{name: 'Buchi nella registrazione', y: {$gap}, color:'#b91d47'}},
                                                                        {{name: 'Parole o frasi non chiare', y: {$unclear}, color:'#00aba9'}},
                                                                        {{name: 'Pause', y: {$pause}, color:'#2b5797'}},
                                                                        {{name: 'Esclamazioni', y: {$vocal}, color:'#ffb900'}},
                                                                        {{name: 'Rumori accidentali', y: {$incident}, color:'#7e3878'}},
                                                                        {{name: 'Movimenti', y: {$kinesic}, color:'#ff7c43'}},
                                                                        
                                                                    ]
                                                                }}]
                                                            }});
                                                
                                                
                                                    
                                                        </script>
                                    
                                        
                                                    </div>
                                            </figure>
                                        </div>
                                        
                                </div>
                                
                                
                                <h2 style="text-align:center;margin-top:80px;">Come si esprime <em>{$testimone}</em> nella testimonianza</h2>
                                <p style="text-align:center;margin-top:25px;padding-left:50px;padding-right:50px;"> Il grafico pone l'attenzione sul modo di esprimersi del testimone, riportando statistiche riguardanti le parole o le frasi riformulate, ripetute, corrette o interrotte durante l'enunciato, le parole errate, quelle espresse in forma dialettale, le parole abbreviate, enfatizzate, ovvero pronunciate con un'enfasi diversa, e le parole in lingua diversa rispetto alla lingua principale della testimonianza.</p>
                                
                                <div class="statistiche">
                                
                                      
                                        
                                        <div id="grafico_fenomeni1">
                                            <!--<canvas id="parole_orale"></canvas>-->
                                            
                                            
                                            <figure class="highcharts-figure">
                                                <div id="container7">
                                                                                        
                                            
                                            
                                                    <script>
                                                        
                                                        Highcharts.chart('container7', {{
                                                            chart: {{
                                                                type: 'bar' // Imposta il tipo di grafico come 'bar' come specificato
                                                            }},
                                                            title: {{
                                                                text: null
                                                            }},
                                                            xAxis: {{
                                                                categories: [
                                                                    'Frasi riformulate', 
                                                                    'Parole corrette', 
                                                                    'Parole troncate', 
                                                                    'Parole ripetute', 
                                                                    'Parole errate', 
                                                                    'Parole dialettali', 
                                                                    'Parole abbreviate', 
                                                                    'Parole enfatizzate', 
                                                                    'Parole in lingua straniera'
                                                                ],
                                                                title: {{
                                                                    text: null
                                                                }},
                                                                labels:{{
                                                                    style:{{
                                                                        fontSize:'12px;'
                                                                    }}
                                                                }},
                                                            }},
                                                            yAxis: {{
                                                                min: 0,
                                                                title: {{
                                                                    text: null
                                                                }}
                                                            }},
                                                            tooltip: {{
                                                                valueSuffix: ' '
                                                            }},
                                                            plotOptions: {{
                                                                bar: {{
                                                                    dataLabels: {{
                                                                        enabled: true,
                                                                        style:{{
                                                                           fontSize:'12px;',
                                                                          
                                                                            
                                                                        }},
                                                                        formatter: function() {{
                                                                            let sum = this.series.data.reduce((acc, point) => acc + point.y, 0);
                                                                            let percentage = Math.round((this.y / sum) * 100) + '%';
                                                                            return `${{percentage}} (${{this.y}})`; // Mostra sia la percentuale che il valore assoluto
                                                                        }}
                                                                    }},
                                                                    
                                                                     pointWidth: 30
                                                                }}
                                                            }},
                                                            series: [{{
                                                                name: 'Occorrenze',
                                                                color: 'black',
                                                                data: [
                                                                    {{ y: {$del_reformulation}, color: '#b91d47' }},  // Frasi riformulate
                                                                    {{ y: {$del_correction}, color: '#00aba9' }},     // Parole corrette
                                                                    {{ y: {$del_truncation}, color: '#2b5797' }},     // Parole troncate
                                                                    {{ y: {$del_repetition}, color: '#e8c3b9' }},     // Parole ripetute
                                                                    {{ y: {$sic}, color: '#1e7145' }},                // Parole errate
                                                                    {{ y: {$orig}, color: '#8c53e0' }},               // Parole dialettali
                                                                    {{ y: {$abbr}, color: '#edd774' }},               // Parole abbreviate
                                                                    {{ y: {$emph}, color: '#97d2f0' }},               // Parole enfatizzate
                                                                    {{ y: {$foreign}, color: '#f79452' }}             // Parole in lingua straniera
                                                                ]
                                                            }}],
                                                            credits: {{
                                                                enabled: false
                                                            }}
                                                        }});
        
                                                    </script>
                                                </div>
                                            </figure>
                                        </div>
                                        
                                       
                                        
                                    
                                </div>
                                
                                
                                <h2 style="text-align:center;margin-top:80px;">Entità nominate nella testimonianza di <em>{$testimone}</em></h2>
                                <p style="text-align:center;margin-top:25px;padding-left:50px;padding-right:50px;">Il grafico a sinistra mostra le entità nominate citate nel testo, quindi quante persone, quanti luoghi e quante organizzazioni compaiono. Il grafico a destra mostra invece quanti nomi vengono citati.</p>
                                
                                        
                                
                                <div class="statistiche">
                                
                                      
                                        
                                        <div id="grafico_fenomeni1">
                                            <!--<canvas id="grafico_entita_orale"></canvas>-->
                                            
                                           <figure class="highcharts-figure">
                                                <div id="container6">
                                                    
                                                    <script>
                                                        Highcharts.chart('container6', {{
                                                                chart: {{
                                                                    type: 'column'
                                                                }},
                                                                title: {{
                                                                    text: null
                                                                }},
                                                               
                                                                xAxis: {{
                                                                    categories: ['Persone', 'Luoghi', 'Organizzazioni'],
                                                                    crosshair: true,
                                                                    accessibility: {{
                                                                        description: 'Entità nominate'
                                                                    }}
                                                                }},
                                                                yAxis: {{
                                                                    min: 0,
                                                                    title: {{
                                                                        text: ''
                                                                    }}
                                                                }},
                                                                tooltip: {{
                                                                    valueSuffix: ''
                                                                }},
                                                                plotOptions: {{
                                                                    column: {{
                                                                        pointPadding: 0.2,
                                                                        borderWidth: 0
                                                                    }}
                                                                }},
                                                                series: [
                                                                    {{
                                                                        name: 'Totale entità presenti nella testimonianza',
                                                                        data: [{$person}, {$place}, {$org}],
                                                                        color: '#2b5797'
                                                                    }},
                                                                    {{
                                                                        name: 'Numero di occorrenze nella testimonianza',
                                                                        data: [{$persName}, {$placeName}, {$orgName}],
                                                                        color: '#b91d47'
                                                                    }}
                                                                ]
                                                            }});
                                                    </script>
                                                </div>
                                                    
                                                    
                                            </figure>
                                        </div>
                                                
                                                
                                </div>
                                
                                 
                                 
                                 
                                 
                                 
                                <h2 style="text-align:center;margin-top:80px;margin-bottom:80px;" >Le seguenti tabelle riportano l'elenco delle persone, dei luoghi e delle organizzazioni che sono state citate dal testimone, ordinando i risultati in base al numero di occorrenze.</h2>
                                
                                <div>
                                    <h2 style="text-align:center;margin-bottom:25px; padding-left:50px;padding-right:50px;"><em>Quali persone e quante volte vengono citate nella testimonianza?</em></h2>
                                        <div id="tabella_persone" class="section_tabella">
                                        
                                            
                                            <table class="tabella">
                                              <tr>
                                                <th>ID</th>
                                                <th>Occorrenze</th>
                                                <th>Nome</th>
                                                <th>Note</th>
                                                <th>Sesso</th>
                                                <th>Nascita</th>
                                                <th>Morte</th>
                                                <th>Link</th>
                                              </tr>
                                              {
                                                  
                                                for $person in $lista_persone
                                                    let $x:=data($person/@xml:id)
                                                    let $occorrenze:=count($text//tei:persName[@ref=concat("#",$x)])
                                                    order by $occorrenze descending
                                                return
                                                <tr>
                                                  <td>{data($person/@xml:id)}</td>
                                                  <td>{$occorrenze}</td>
                                                  <td>{$person/tei:persName}</td>
                                                  <td>{if ($person/tei:note) then ($person/tei:note) else "/"}</td>
                                                  <td>{$person/tei:sex}</td>
                                                  <td>{if ($person/tei:birth/tei:date and $person/tei:birth/tei:placeName) then concat($person/tei:birth/tei:date, " (", fn:normalize-space($person/tei:birth/tei:placeName), ")")
                                                        else if ($person/tei:birth/tei:date) then $person/tei:birth/tei:date
                                                        else if ($person/tei:birth/tei:placeName) then fn:normalize-space($person/tei:birth/tei:placeName) else "/"}</td>
                                                  <td>{if ($person/tei:death/tei:date and $person/tei:death/tei:placeName) then concat($person/tei:death/tei:date, " (", fn:normalize-space($person/tei:death/tei:placeName), ")")
                                                        else if ($person/tei:death/tei:date) then $person/tei:death/tei:date
                                                        else if ($person/tei:death/tei:placeName) then fn:normalize-space($person/tei:death/tei:placeName) else "/"}</td>
                                                   <td>{if ($person/@source) then <a href="{data($person/@source)}" target="blank">Scopri di più</a>
                                                        else " "}</td>
                                                </tr>
                                              }
                                            </table>
                                            
                                        </div>
                                        
                                        <h2 style="text-align:center;margin-bottom:25px; padding-left:50px;padding-right:50px;"><em>Quali luoghi e quante volte vengono citati nella testimonianza?</em></h2>
                                        <div id="tabella_luoghi" class="section_tabella">
                                        
                                            <table class="tabella"> 
                                                  <tr>
                                                    <th>ID</th>
                                                    <th>Occorrenze</th>
                                                    <th>Nome</th>
                                                    <th>Provincia/Regione</th>
                                                    <th>Stato</th>
                                                    <th>Link</th>
                                                  </tr>
                                                  {
                                                      
                                                    for $place in $lista_luoghi
                                                        let $x:=data($place/@xml:id)
                                                        let $occorrenze:=count($text//tei:placeName[@ref=concat("#",$x)])
                                                        order by $occorrenze descending
                                                    return
                                                    <tr>
                                                      <td>{data($place/@xml:id)}</td>
                                                      <td>{$occorrenze}</td>
                                                      <td>{$place/tei:placeName}</td>
                                                      <td>{
                                                          if ($place/tei:settlement[@type="province"] and $place/tei:settlement[@type="region"]) then
                                                            concat($place/tei:settlement[@type="province"], ", ", $place/tei:settlement[@type="region"])
                                                          else if ($place/tei:settlement[@type="province"]) then
                                                            $place/tei:settlement[@type="province"]
                                                          else if ($place/tei:settlement[@type="region"]) then
                                                            $place/tei:settlement[@type="region"]
                                                          else
                                                            "/"
                                                        }
                                                      </td>
                                                      <td>{$place/tei:country}</td>
                                                      <td>{if ($place/@source) then <a href="{data($place/@source)}" target="blank">Scopri di più</a>
                                                            else " "}</td>
                                                    </tr>
                                                  }
                                            </table>
                                        
                                        </div>
                                        
                                        
                                         <h2 style="text-align:center;margin-bottom:25px; padding-left:50px;padding-right:50px;"><em>Quali organizzazioni e quante volte vengono citate nella testimonianza?</em></h2>
                                            <div id="tabella_organizzazioni" class="section_tabella">
                                            
                                                <table class="tabella">
                                                      <tr>
                                                        <th>ID</th>
                                                        <th>Occorrenze</th>
                                                        <th>Nome</th>
                                                        <th>Sede</th>
                                                        <th>Descrizione</th>
                                                        <th>Link</th>
                                                      </tr>
                                                      {
                                                          
                                                        for $org in $lista_org
                                                            let $x:=data($org/@xml:id)
                                                            let $occorrenze:=count($text//tei:orgName[@ref=concat("#",$x)])
                                                            order by $occorrenze descending
                                                        return
                                                        <tr>
                                                          <td>{data($org/@xml:id)}</td>
                                                          <td>{$occorrenze}</td>
                                                          <td>{$org/tei:orgName}</td>
                                                          <td>{$org/tei:placeName}</td>
                                                          <td>{$org/tei:desc}</td>
                                                          <td>{if ($org/@source) then <a href="{data($org/@source)}" target="blank">Scopri di più</a>
                                                                else " "}</td>
                                                        </tr>
                                                      }
                                                </table>
                                            </div>
                                            
                                        
                                         
                                         <!--tabella biblioteca-->
                                         
                                         <h2 style="text-align:center; margin-bottom:25px; padding-left:50px; padding-right:50px;"><em>La biblioteca di {$testimone}</em></h2>
                                        <div id="tabella_biblioteca" class="section_tabella">
                                        
                                        <table class="tabella"> 
                                              <tr>
                                                <th>ID</th>
                                                <th>Occorrenze</th>
                                                <th>Autore</th>
                                                <th>Titolo</th>
                                                <th>Luogo di pubblicazione</th>
                                                <th>Editore</th>
                                                <th>Data</th>
                                              </tr>
                                               {
                                                  
                                               for $bibl in $lista_bibl_sec
                                                    let $x:=data($bibl/@xml:id)
                                                    let $occorrenze := count(
                                                        $text//(
                                                          tei:title[@ref=concat("#", $x)] |
                                                          tei:ref[@target=concat("#", $x)]
                                                        )
                                                      )
                                                    order by $occorrenze descending
                                                return
                                                <tr>
                                                    <td>{data($bibl/@xml:id)}</td>
                                                    <td>{$occorrenze}</td>
                                                    <td>{$bibl//tei:author}</td>
                                                   
                                                    <td>{data($bibl//tei:title)}</td>
                                                    
                                                    <td>{if (empty($bibl/tei:pubPlace)) then
                                                                "/"
                                                             else
                                                                $bibl/tei:pubPlace}
                                                        </td>
                                                      <td>{if (empty($bibl/tei:publisher)) then
                                                                "/"
                                                             else
                                                                $bibl/tei:publisher}
                                                        </td>
                                                      <td>{if ($bibl instance of element(tei:bibl)) then
                                                                $bibl/tei:date
                                                              else
                                                                $bibl/tei:monogr/tei:imprint/tei:date}
                                                    </td>  
                                                    
                                                
                                                    <!--CODICE DI CHIARA-->
                                                    
                                                    <!--<td>{data($bibl/@xml:id)}</td>
                                                    <td>{$occorrenze}</td>
                                                    <td>{if ($bibl instance of element(tei:bibl)) then
                                                                $bibl/tei:author
                                                            else
                                                                $bibl/tei:monogr/tei:author}
                                                      </td>
                                                    <td>{
                                                              if ($bibl instance of element(tei:bibl)) then
                                                                string($bibl//tei:title)
                                                              else
                                                                let $titles := (
                                                                  $bibl/tei:series/tei:title,
                                                                  $bibl/tei:monogr/tei:title,
                                                                  $bibl/tei:analytic/tei:title
                                                                )
                                                                return string-join($titles, ",")
                                                            }
                                                      </td>
                                                      <td>{if (empty($bibl/tei:pubPlace)) then
                                                                "/"
                                                             else
                                                                $bibl/tei:pubPlace}
                                                        </td>
                                                      <td>{if (empty($bibl/tei:publisher)) then
                                                                "/"
                                                             else
                                                                $bibl/tei:publisher}
                                                        </td>
                                                      <td>{if ($bibl instance of element(tei:bibl)) then
                                                                $bibl/tei:date
                                                              else
                                                                $bibl/tei:monogr/tei:imprint/tei:date}
                                                      </td> -->
                                                    
                                                </tr>
                                              }
                                            </table>
                                        
                                        </div>
                                               
                                    
                                </div>
                      
                            </div>
           
            return $statistiche_orale
            
    return $tipo
}; 











declare function app:dante($node as node(), $model as map(*)){
    let $titolotestimonianza :=request:get-parameter("titolotestimonianza","")
    
    let $xmlCollection:=collection("/db/apps/voci_inferno/xml")
    let $filexml := 
        for $xml in $xmlCollection/*
        let $titolo := fn:normalize-space($xml//tei:title[@xml:id="titolotestimonianza"])
        where $titolo = $titolotestimonianza
        return $xml

    let $testimone := concat($filexml//tei:person[@role="testimone"]//tei:persName//tei:forename," ",$filexml//tei:person[@role="testimone"]//tei:persName//tei:surname[1])
    
    let $citazioni_esplicite:=$filexml//tei:text//tei:cit[@type="explicit"]
    let $citazioni_implicite:=$filexml//tei:text//tei:cit[@type="implicit"]
    let $riferimenti_dante:=$filexml//tei:text//tei:ref[@type="allusion"]
    let $termini_danteschi:=$filexml//tei:text//tei:term[@type="dante"]
    let $totale_tessere := count($citazioni_esplicite) + count($citazioni_implicite)+count($riferimenti_dante)+count($termini_danteschi)
    
    
    let $testo_dante:=doc("/db/apps/voci_inferno/DivinaCommedia/Inferno/Dante_Artom.xml")
    
    let $lista_div:=$testo_dante//tei:body//tei:div
    
    
    
    
    return 
        
        <div>
            <h2 style="text-align:center;margin-top:10%;">Il Dante di <em>{$testimone}</em></h2>
            <div style="text-align:center;margin-top:30px;">
                <p>Nella testimonianza di <em>{$testimone}</em> sono presenti <b>{$totale_tessere}</b> tessere dantesche, di cui:</p>
                <br/>
                <p>
                Citazioni esplicite: <b>{count($citazioni_esplicite)}</b><br/> 
                Citazioni implicite: <b>{count($citazioni_implicite)}</b><br/> 
                Allusioni / riferimenti: <b>{count($riferimenti_dante)}</b><br/>
                Termini danteschi: <b>{count($termini_danteschi)}</b>
                </p>
            </div>
            
            <div class="section_dante">    
                <div class="citazioni" id ="citazioni">
                
                     <!--condizione per gestire elenco citazioni in caso di presenza/assenza-->
                    {
                    if ($citazioni_esplicite) then
                    <section>
                        <h3>Citazioni esplicite</h3>
                        <ul>{
                            for $cit_espl at $index in $citazioni_esplicite
                            let $quote:=$cit_espl//tei:quote
                            let $versetti:=$cit_espl//tei:bibl
                            let $id := concat("cit_esp", $index)
                            (:  :for $q in $quote
                            let $lista_l:=$q//tei:l
                            for $l in $lista_l :)
                            return <li id="{$id}" style="cursor:pointer;"><em>{$quote}</em><br/>({concat($versetti, "")})</li>
                        }
                            
                        </ul>
                    </section>
                    
                    else ()
                    }   
                
                    
                    {
                    if ($citazioni_implicite) then
                    <section>
                        <h3>Citazioni implicite</h3>
                        <ul>{
                            for $cit_impl at $index in $citazioni_implicite
                                let $quote := $cit_impl//tei:quote
                                let $versetti:=$cit_impl//tei:bibl
                                let $id := concat("cit_imp", $index)
                                return
                                  <li id="{$id}" style="cursor:pointer;">{$quote}<br/>({concat($versetti, "")})</li>

                    }
                        </ul>
                    </section>
                    
                    else ()
                    }
                    
                     
                    {
                    if ($riferimenti_dante) then
                    <section>
                        <h3>Allusioni / riferimenti:</h3>
                        <ul>{
                            for $ref at $index in $riferimenti_dante
                               
                                let $versetti:=$ref//tei:bibl
                                let $id := concat("cit_imp", $index)
                                return
                                  <li id="{$id}" style="cursor:pointer;">{$ref}<br/></li>

                    }
                        </ul>
                    </section>
                    
                    else ()
                    }
                    
                      
                    {
                    if ($termini_danteschi) then
                    <section>
                        <h3>Termini danteschi:</h3>
                        <ul>{
                             (: for $t at $index in $termini_danteschi
                               
                                :let $versetti:=$t//tei:bibl
                                let $id := concat("cit_imp", $i:index :)
                            for $t in $termini_danteschi 
                                let $chiave := fn:normalize-space(fn:lower-case($t))
                                group by $chiave
                                
                                return
                                    <li><pre> {concat($chiave, " ")} <b>{count($t)}</b></pre></li>
                                    
                                (: non compaiono più ripetizioni dello stesso termine nella lista ma vengono contati  :)

                    }
                        </ul>
                    </section>
                    
                    else ()
                    }
                    
                    
                    
                    
                    
                </div>
                
                <div id="divina_commedia">
                    <i onclick="closePopUp()" style="font-size:24px; float:right; cursor: pointer;" class="fa">&#xf00d;</i>
                    
                    <br/>
                    
                    
                    
                    <p>{for $div in $lista_div
                        
                        let $lista_lg:=$div//tei:lg
                        let $title:=data($div/tei:title)
                        
                    
                        (:  :for $lg in $lista_lg:)
                       
                        return
                            <div>
                            <p><b>{$title}</b></p>
                            <br/>
                            <p>{
                                for $lg in $lista_lg
                                let $lista_l:=$lg//tei:l
                                
                                return <p>{for $l in $lista_l
                                return <p><em>{$l}</em></p>}<br/></p>
                                }
                                
                            </p>
                            
                            <!-- <p><em>{$lg}</em></p>-->
                            <br/>
                            </div>
                    }
                        
                    </p>
                    
                </div>
                
                
                
                <script><![CDATA[
                document.getElementById('cit_esp1').addEventListener('click', function() {
                    showPopUp('l[xml\\:id="canto6_4_1"], l[xml\\:id="canto6_4_2"]', 'cit_esp1');
                });
                document.getElementById('cit_imp1').addEventListener('click', function() {
                    showPopUp('l[xml\\:id="canto6_18_1"], l[xml\\:id="canto6_18_2"], l[xml\\:id="canto6_18_3"]', 'cit_imp1');
                });
                document.getElementById('cit_imp3').addEventListener('click', function() {
                    showPopUp('l[xml\\:id="canto21_l139"]', 'cit_imp3');
                });
                document.getElementById('cit_imp2').addEventListener('click', function() {
                    showPopUp('l[xml\\:id="canto13_37_1"], l[xml\\:id="canto13_37_2"], l[xml\\:id="canto13_37_3"], l[xml\\:id="canto13_38_1"], l[xml\\:id="canto13_38_2"], l[xml\\:id="canto13_38_3"]', 'cit_imp2');
                });
                ]]></script>

               
                
                
            </div>
            
        </div>
};



declare function app:corpus_dante($node as node(), $model as map(*)){
    
    let $xmlCollection:=collection("/db/apps/voci_inferno/xml")
    
    (: conto il numero totale di testimoni presenti nell'archivio :)
    let $num_archivio:=local:contaTestimoniCollezione("/db/apps/voci_inferno/xml")-1
    
    
    
    (: conto quante sono le testimonianze totali:)
    let $titoli := 
        for $xml in $xmlCollection/*
        let $find_testimone := $xml//tei:person[@role="testimone"]
        (:  :let $nome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:forename)
        let $cognome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:surname)
        
        where $cognome_testimone = $testimone_split[1] and $nome_testimone = $testimone_split[2] :)
        for $titolo in $xml//tei:title[@xml:id="titolotestimonianza"]
        return fn:normalize-space(string($titolo))
        
    let $num_testimonianze :=count($titoli)  
    
    
    
    
    
    (: conto quante sono le citazioni implicite :)
    let $num_citazioni_implicite := 
    
        for $xml in $xmlCollection/*
        
        let $citazioni_implicite:=$xml//tei:text//tei:cit[@type="implicit"]

        return $citazioni_implicite
        
        
    (: conto quante sono le citazioni esplicite :)
    let $num_citazioni_esplicite := 
        for $xml in $xmlCollection/*
        
        let $citazioni_esplicite:=$xml//tei:text//tei:cit[@type="explicit"]

        return $citazioni_esplicite
        
    
    (:  conto quanti sono i riferimenti più generici alla Commedia :)
     let $num_riferimenti_dante := 
        for $xml in $xmlCollection/*
        
        let $riferimenti:=$xml//tei:text//tei:ref[@type="allusion"]

        return $riferimenti
        
    (:  conto quanti sono i termini danteschi :)
     let $num_termini_dante := 
        for $xml in $xmlCollection/*
        
        let $termini:=$xml//tei:text//tei:term[@type="dante"]

        return $termini
        
        
    (: totale citazioni o riferimenti a Dante  :)
    let $tot_citazioni:=count($num_citazioni_implicite)+count($num_citazioni_esplicite)+count($num_riferimenti_dante)+count($num_termini_dante)
    

            (: CITAZIONI IMPLICITE : CONTEGGIO INFERNO, PURGATORIO, PARADISO :)
    
    
            (: conteggio totale dei canti per "Inferno" :)
            let $inferno_count_implicite :=
            sum(
                for $xml in $xmlCollection/*
                let $target := $xml//tei:text//tei:cit[@type="implicit"]/tei:ref/@target/string()
                
                let $inferno_canti :=
                    for $t in $target
                    let $target_tokenize := tokenize($t, "#")[2]
                    let $bibl := $xml//tei:standOff//tei:listBibl//tei:biblStruct[@xml:id = $target_tokenize]
                    let $is_inferno := $bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Inferno")]
                    
                    return if ($is_inferno) then 1 else 0
                
                return $inferno_canti
            )

        
           (: conteggio totale dei canti per "Purgatorio" :)
            let $purgatorio_count_implicite :=
            sum(
                for $xml in $xmlCollection/*
                let $target := $xml//tei:text//tei:cit[@type="implicit"]/tei:ref/@target/string()
                
                let $purgatorio_canti :=
                    for $t in $target
                    let $target_tokenize := tokenize($t, "#")[2]
                    let $bibl := $xml//tei:standOff//tei:listBibl//tei:biblStruct[@xml:id = $target_tokenize]
                    let $is_purgatorio := $bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Purgatorio")]
                    
                    return if ($is_purgatorio) then 1 else 0
                
                return $purgatorio_canti
            )
            
             
           (: conteggio totale dei canti per "Paradiso" :)
            let $paradiso_count_implicite :=
            sum(
                for $xml in $xmlCollection/*
                let $target := $xml//tei:text//tei:cit[@type="implicit"]/tei:ref/@target/string()
                
                let $paradiso_canti :=
                    for $t in $target
                    let $target_tokenize := tokenize($t, "#")[2]
                    let $bibl := $xml//tei:standOff//tei:listBibl//tei:biblStruct[@xml:id = $target_tokenize]
                    let $is_paradiso := $bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Paradiso")]
                    
                    return if ($is_paradiso) then 1 else 0
                
                return $paradiso_canti
            )
               

       
            (: CITAZIONI ESPLICITE : CONTEGGIO INFERNO, PURGATORIO, PARADISO :)
    
            (: conteggio totale dei canti per "Inferno" :)
            let $inferno_count_esplicite :=
            sum(
                for $xml in $xmlCollection/*
                let $target := $xml//tei:text//tei:cit[@type="explicit"]/tei:ref/@target/string()
                
                let $inferno_canti :=
                    for $t in $target
                    let $target_tokenize := tokenize($t, "#")[2]
                    let $bibl := $xml//tei:standOff//tei:listBibl//tei:biblStruct[@xml:id = $target_tokenize]
                    let $is_inferno := $bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Inferno")]
                    
                    return if ($is_inferno) then 1 else 0
                
                return $inferno_canti
            )
        
        
           (: conteggio totale dei canti per "Purgatorio" :)
            let $purgatorio_count_esplicite :=
            sum(
                for $xml in $xmlCollection/*
                let $target := $xml//tei:text//tei:cit[@type="explicit"]/tei:ref/@target/string()
                
                let $purgatorio_canti :=
                    for $t in $target
                    let $target_tokenize := tokenize($t, "#")[2]
                    let $bibl := $xml//tei:standOff//tei:listBibl//tei:biblStruct[@xml:id = $target_tokenize]
                    let $is_purgatorio := $bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Purgatorio")]
                    
                    return if ($is_purgatorio) then 1 else 0
                
                return $purgatorio_canti
            )
            
             
           (: conteggio totale dei canti per "Paradiso" :)
            let $paradiso_count_esplicite :=
            sum(
                for $xml in $xmlCollection/*
                let $target := $xml//tei:text//tei:cit[@type="explicit"]/tei:ref/@target/string()
                
                let $paradiso_canti :=
                    for $t in $target
                    let $target_tokenize := tokenize($t, "#")[2]
                    let $bibl := $xml//tei:standOff//tei:listBibl//tei:biblStruct[@xml:id = $target_tokenize]
                    let $is_paradiso := $bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Paradiso")]
                    
                    return if ($is_paradiso) then 1 else 0
                
                return $paradiso_canti
            )
            
            
            
            (: ALLUSIONI : CONTEGGIO INFERNO, PURGATORIO, PARADISO :)
               
            (: conteggio totale dei canti per "Inferno" :)
            let $inferno_count_allusioni :=
            sum(
                for $xml in $xmlCollection/*
                let $target := $xml//tei:text//tei:ref[@type="allusion"]//@target/string()
                
                let $inferno_canti :=
                    for $t in $target
                    let $target_tokenize := tokenize($t, "#")[2]
                    let $bibl := $xml//tei:standOff//tei:listBibl//tei:biblStruct[@xml:id = $target_tokenize]
                    let $is_inferno := $bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Inferno")]
                    
                    return if ($is_inferno) then 1 else 0
                
                return $inferno_canti
            )  
            
            
            (: conteggio totale dei canti per "Purgatorio" :)
            let $purgatorio_count_allusioni :=
            sum(
                for $xml in $xmlCollection/*
                let $target := $xml//tei:text//tei:ref[@type="allusion"]//@target/string()
                
                let $purgatorio_canti :=
                    for $t in $target
                    let $target_tokenize := tokenize($t, "#")[2]
                    let $bibl := $xml//tei:standOff//tei:listBibl//tei:biblStruct[@xml:id = $target_tokenize]
                    let $is_purgatorio := $bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Purgatorio")]
                    
                    return if ($is_purgatorio) then 1 else 0
                
                return $purgatorio_canti
            )  
             
             
            (: conteggio totale dei canti per "Paradiso" :)
            let $paradiso_count_allusioni :=
            sum(
                for $xml in $xmlCollection/*
                let $target := $xml//tei:text//tei:ref[@type="allusion"]//@target/string()
                
                let $paradiso_canti :=
                    for $t in $target
                    let $target_tokenize := tokenize($t, "#")[2]
                    let $bibl := $xml//tei:standOff//tei:listBibl//tei:biblStruct[@xml:id = $target_tokenize]
                    let $is_paradiso := $bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Paradiso")]
                    
                    return if ($is_paradiso) then 1 else 0
                
                return $paradiso_canti
            )
    
    
    
    
    
    (: conto quante sono le citazioni totali all'Inferno (sia implicite che esplicite :)
    let $tot_citazioni_inferno:=$inferno_count_implicite+$inferno_count_esplicite
    
    (: conto quante sono le citazioni totali al Purgatorio (sia implicite che esplicite :)
    let $tot_citazioni_purgatorio:=$purgatorio_count_implicite+$purgatorio_count_esplicite
    
    (: conto quante sono le citazioni totali al Paradiso (sia implicite che esplicite :)
    let $tot_citazioni_paradiso:=$paradiso_count_implicite+$paradiso_count_esplicite


    (: conto occorrenze termini danteschi :)
    let $termini_danteschi := 
        for $xml in $xmlCollection/*
        let $lista_term := $xml//tei:text//tei:term[@type="dante"]
        return for $term in $lista_term
               return fn:normalize-space(fn:lower-case($term))
    
    let $tot_termini_danteschi := count($termini_danteschi)
    
    let $occorrenze_termini_dante :=
        for $term in distinct-values($termini_danteschi)
        let $occorrenze := count($termini_danteschi[. = $term])
        order by $occorrenze descending
        return
            <p><b>{$term}</b>: {$occorrenze}</p>
            
    
    (: mi serve per prepare l'output json per il grafico :)
    let $occorrenze_termini_dante_per_json :=
        for $term in distinct-values($termini_danteschi)
        let $occorrenze := count($termini_danteschi[. = $term])
        order by $occorrenze descending
        return
            concat('{"name": "', $term, '", "y": ', $occorrenze, '}')  
    
    let $termini_dante_output_json :='[' || string-join($occorrenze_termini_dante_per_json, ', ') || ']'




         (: chi usa più termini danteschi :)
        let $termini_per_testimone :=
            for $xml in $xmlCollection/*
            let $testimone := $xml//tei:person[@role="testimone"]
            let $nome_testimone := fn:normalize-space($testimone//tei:forename || " " || $testimone//tei:surname[1])
            let $termine := $xml//tei:text//tei:term[@type="dante"]
            let $num_termini := count($termine)
            where $num_termini > 0
            order by $num_termini descending
            return 
                concat('{"name": "', $nome_testimone, '", "y": ', $num_termini, '}')  
                (:   <p><b>{$nome_testimone}</b> cita implicitamente la <em>Commedia </em> <b>{ $num_citazioni}</b> volte </p> :)
                    
        
         let $termini_json_output :=  '[' || string-join($termini_per_testimone, ', ') || ']'
                
         (: questo mi serve solo per la stampa dei nomi di chi usa termini danteschi :)
         let $termini_per_testimone_names :=
            for $xml in $xmlCollection/*
            let $testimone := $xml//tei:person[@role="testimone"]
            let $nome_testimone := fn:normalize-space($testimone//tei:forename || " " || $testimone//tei:surname[1])
            let $termine := $xml//tei:text//tei:term[@type="dante"]
            let $num_termini := count($termine)
            where $num_termini > 0
            order by $num_termini descending
            return 
                  $nome_testimone
    
        let $num_testimoni_con_termini_danteschi:=count($termini_per_testimone_names)
        
        
   
        (: conto quali sono i canti più citati, tra citazioni implicite e esplicite, di ciascuna Cantica :)
         
        (: occorrenze canti Inferno :)                      
        let $canti_inferno := 
            for $xml in $xmlCollection/*
            let $citazioni := $xml//tei:text//tei:cit[@type="implicit" or @type="explicit"] 
            
            for $cit in $citazioni
            let $target := $cit/tei:ref/@target/string()
            let $target_tokenize := tokenize($target, "#")[2]
            let $bibl := $xml//tei:standOff//tei:listBibl//tei:biblStruct[@xml:id = $target_tokenize]
            let $is_inferno := $bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Inferno")]
            let $titolo := $bibl//tei:analytic//tei:title[@level="a"]
            
            where $is_inferno
            return $titolo
        
        
        let $occorrenze_canti_inferno := 
            for $titolo in distinct-values($canti_inferno)
            let $occorrenze := count($canti_inferno[. = $titolo])
            order by $occorrenze descending
            return 
                concat('{"name": "', $titolo, '", "y": ', $occorrenze, '}')  
                

         let $occorrenze_canti_inferno_json_output := 
        '[' || string-join($occorrenze_canti_inferno, ', ') || ']'
        
                
        
        (: occorrenze canti Purgatorio :)                      
        let $canti_purgatorio := 
            for $xml in $xmlCollection/*
            let $citazioni := $xml//tei:text//tei:cit[@type="implicit" or @type="explicit"]
            
            for $cit in $citazioni
            let $target := $cit/tei:ref/@target/string()
            let $target_tokenize := tokenize($target, "#")[2]
            let $bibl := $xml//tei:standOff//tei:listBibl//tei:biblStruct[@xml:id = $target_tokenize]
            let $is_inferno := $bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Purgatorio")]
            let $titolo := $bibl//tei:analytic//tei:title[@level="a"]
            
            where $is_inferno
            return $titolo
        
        
        let $occorrenze_canti_purgatorio := 
            for $titolo in distinct-values($canti_purgatorio)
            let $occorrenze := count($canti_purgatorio[. = $titolo])
            order by $occorrenze descending
            return 
                concat('{"name": "', $titolo, '", "y": ', $occorrenze, '}') 
        
        let $occorrenze_canti_purgatorio_json_output := 
        '[' || string-join($occorrenze_canti_purgatorio, ', ') || ']'      
            
                
        
        (: occorrenze canti Paradiso :)                        
         let $canti_paradiso := 
            for $xml in $xmlCollection/*
            let $citazioni := $xml//tei:text//tei:cit[@type="implicit" or @type="explicit"]
            
            for $cit in $citazioni
            let $target := $cit/tei:ref/@target/string()
            let $target_tokenize := tokenize($target, "#")[2]
            let $bibl := $xml//tei:standOff//tei:listBibl//tei:biblStruct[@xml:id = $target_tokenize]
            let $is_inferno := $bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Paradiso")]
            let $titolo := $bibl//tei:analytic//tei:title[@level="a"]
            
            where $is_inferno
            return $titolo
        
        
        let $occorrenze_canti_paradiso := 
            for $titolo in distinct-values($canti_paradiso)
            let $occorrenze := count($canti_paradiso[. = $titolo])
            order by $occorrenze descending
            return 
                concat('{"name": "', $titolo, '", "y": ', $occorrenze, '}')  

         let $occorrenze_canti_paradiso_json_output := 
        '[' || string-join($occorrenze_canti_paradiso, ', ') || ']'      
            



        (: conto quali sono i canti a cui vengono fatte più allusioni per ciascuna cantica :)
         
        (: occorrenze canti Inferno allusioni :)                      
        let $canti_inferno_allusioni := 
            for $xml in $xmlCollection/*
            let $citazioni := $xml//tei:text//tei:ref[@type="allusion"] 
            
            for $cit in $citazioni
            let $target := $cit/@target/string()
            let $target_tokenize := tokenize($target, "#")[2]
            let $bibl := $xml//tei:standOff//tei:listBibl//tei:biblStruct[@xml:id = $target_tokenize]
            let $is_inferno := $bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Inferno")]
            let $titolo := $bibl//tei:analytic//tei:title[@level="a"]
            
            where $is_inferno
            return $titolo
            
        
        let $occorrenze_canti_inferno_allusioni := 
            for $titolo in distinct-values($canti_inferno_allusioni)
            let $occorrenze := count($canti_inferno_allusioni[. = $titolo])
            order by $occorrenze descending
            return 
                
                <p><b>{$titolo}</b>: {$occorrenze}</p>
                
                
        (: occorrenze canti Purgatorio allusioni:)                      
        let $canti_purgatorio_allusioni := 
            for $xml in $xmlCollection/*
            let $citazioni := $xml//tei:text//tei:ref[@type="allusion"] 
            
            for $cit in $citazioni
            let $target := $cit/@target/string()
            let $target_tokenize := tokenize($target, "#")[2]
            let $bibl := $xml//tei:standOff//tei:listBibl//tei:biblStruct[@xml:id = $target_tokenize]
            let $is_purgatorio := $bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Purgatorio")]
            let $titolo := $bibl//tei:analytic//tei:title[@level="a"]
            
            where $is_purgatorio
            return $titolo
            
        
        let $occorrenze_canti_purgatorio_allusioni := 
            for $titolo in distinct-values($canti_purgatorio_allusioni)
            let $occorrenze := count($canti_purgatorio_allusioni[. = $titolo])
            order by $occorrenze descending
            return 
                <p><b>{$titolo}</b>: {$occorrenze}</p>
                
        
        (: occorrenze canti Paradiso allusioni:)                      
        let $canti_paradiso_allusioni := 
            for $xml in $xmlCollection/*
            let $citazioni := $xml//tei:text//tei:ref[@type="allusion"] 
            
            for $cit in $citazioni
            let $target := $cit/@target/string()
            let $target_tokenize := tokenize($target, "#")[2]
            let $bibl := $xml//tei:standOff//tei:listBibl//tei:biblStruct[@xml:id = $target_tokenize]
            let $is_paradiso := $bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Paradiso")]
            let $titolo := $bibl//tei:analytic//tei:title[@level="a"]
            
            where $is_paradiso
            return $titolo
            
        
        let $occorrenze_canti_paradiso_allusioni := 
            for $titolo in distinct-values($canti_paradiso_allusioni)
            let $occorrenze := count($canti_paradiso_allusioni[. = $titolo])
            order by $occorrenze descending
            return 
                <p><b>{$titolo}</b>: {$occorrenze}</p>
                
                
      
  
  
        
        
        
        (: estraggo elenco dei testimoni che citano o fanno allusioni a dante :)
        let $testimoni_con_dante := 
            for $xml in $xmlCollection/*
            let $testimone := $xml//tei:person[@role="testimone"]
            let $nome_testimone := fn:normalize-space($testimone//tei:forename || " " || $testimone//tei:surname[1] )
            let $citazioni := $xml//tei:text//tei:cit[@type="explicit" or @type="implicit"] or  $xml//tei:text//tei:ref[@type="allusion"] or $xml//tei:text//tei:term[@type="dante"] 
            where $citazioni
            return $nome_testimone
            
        
        (: conto quanti riferimenti a dante fa ciascun testimone :)
        let $num_testimoni_con_dante:=count($testimoni_con_dante)

            
            
            
        (: conto le citazioni per ciascun testimone :)
        let $dante_per_testimone :=
            for $xml in $xmlCollection/*
            let $testimone := $xml//tei:person[@role="testimone"]
            let $nome_testimone := fn:normalize-space($testimone//tei:forename || " " || $testimone//tei:surname[1] )
            let $citazioni := $xml//tei:text//tei:cit[@type="explicit" or @type="implicit"] 
            let $allusioni:=$xml//tei:text//tei:ref[@type="allusion"]   
            let $termini:=$xml//tei:text//tei:term[@type="dante"]   
            let $num_citazioni := count($citazioni)+count($allusioni)+count($termini)
            where $num_citazioni > 0
            order by $num_citazioni descending
            return
                    concat('{"name": "', $nome_testimone, '", "y": ', $num_citazioni, '}')  
                    (:  :<p><li>{$nome_testimone} - occorrenze: <b>{$num_citazioni}</b></li></p>:)
        
        let $dante_testimone_json_output:='[' || string-join($dante_per_testimone, ', ') || ']'
        
        
        
            
                    
        
        (: chi fa più citazioni esplicite :)
        let $citazioni_esplicite_per_testimone :=
            for $xml in $xmlCollection/*
            let $testimone := $xml//tei:person[@role="testimone"]
            let $nome_testimone := fn:normalize-space($testimone//tei:forename || " " || $testimone//tei:surname[1])
            let $citazioni := $xml//tei:text//tei:cit[@type="explicit"]
            let $num_citazioni := count($citazioni)
            where $num_citazioni > 0
            order by $num_citazioni descending
          
            return 
                  concat('{"name": "', $nome_testimone, '", "y": ', $num_citazioni, '}') 
                   (: <p><b>{$nome_testimone}</b> cita esplicitamente la <em>Commedia </em> <b>{ $num_citazioni}</b> volte </p>:)
                   
        let $cit_esplicite_json_output := '[' || string-join($citazioni_esplicite_per_testimone, ', ') || ']'
        
        (: questo mi serve solo per la stampa dei nomi di chi fa citazioni esplicite :)
         let $esplicite_per_testimone :=
            for $xml in $xmlCollection/*
            let $testimone := $xml//tei:person[@role="testimone"]
            let $nome_testimone := fn:normalize-space($testimone//tei:forename || " " || $testimone//tei:surname[1])
            let $citazioni := $xml//tei:text//tei:cit[@type="explicit"]
            let $num_citazioni := count($citazioni)
            where $num_citazioni > 0
            order by $num_citazioni descending
            return 
                  $nome_testimone
        
        
         (: chi fa più citazioni implicite :)
        let $citazioni_implicite_per_testimone :=
            for $xml in $xmlCollection/*
            let $testimone := $xml//tei:person[@role="testimone"]
            let $nome_testimone := fn:normalize-space($testimone//tei:forename || " " || $testimone//tei:surname[1])
            let $citazioni := $xml//tei:text//tei:cit[@type="implicit"]
            let $num_citazioni := count($citazioni)
            where $num_citazioni > 0
            order by $num_citazioni descending
            return 
                concat('{"name": "', $nome_testimone, '", "y": ', $num_citazioni, '}')  
                (:   <p><b>{$nome_testimone}</b> cita implicitamente la <em>Commedia </em> <b>{ $num_citazioni}</b> volte </p> :)
                    
        
          let $cit_implicite_json_output := 
        '[' || string-join($citazioni_implicite_per_testimone, ', ') || ']'
        
         (: questo mi serve solo per la stampa dei nomi di chi fa citazioni implicite :)
         let $implicite_per_testimone :=
            for $xml in $xmlCollection/*
            let $testimone := $xml//tei:person[@role="testimone"]
            let $nome_testimone := fn:normalize-space($testimone//tei:forename || " " || $testimone//tei:surname[1])
            let $citazioni := $xml//tei:text//tei:cit[@type="implicit"]
            let $num_citazioni := count($citazioni)
            where $num_citazioni > 0
            order by $num_citazioni descending
            return 
                  $nome_testimone
                  
                  
        
         (: chi fa più allusioni :)
        let $allusioni_per_testimone :=
            for $xml in $xmlCollection/*
            let $testimone := $xml//tei:person[@role="testimone"]
            let $nome_testimone := fn:normalize-space($testimone//tei:forename || " " || $testimone//tei:surname[1])
            let $allusioni := $xml//tei:text//tei:ref[@type="allusion"]
            let $num_allusioni := count($allusioni)
            where $num_allusioni > 0
            order by $num_allusioni descending
            return 
                concat('{"name": "', $nome_testimone, '", "y": ', $num_allusioni, '}')  
                (:   <p><b>{$nome_testimone}</b> cita implicitamente la <em>Commedia </em> <b>{ $num_citazioni}</b> volte </p> :)
                    
        
         let $allusioni_json_output :=  '[' || string-join($allusioni_per_testimone, ', ') || ']'
        
         (: questo mi serve solo per la stampa dei nomi di chi fa allusioni :)
         let $allusioni_per_testimone_names :=
            for $xml in $xmlCollection/*
            let $testimone := $xml//tei:person[@role="testimone"]
            let $nome_testimone := fn:normalize-space($testimone//tei:forename || " " || $testimone//tei:surname[1])
            let $allusioni := $xml//tei:text//tei:ref[@type="allusion"]
            let $num_allusioni := count($allusioni)
            where $num_allusioni > 0
            order by $num_allusioni descending
            return 
                  $nome_testimone
                                            

    return 
                <div id="text" style="margin-top:50px;">
                        <head>
                          <script src="http://code.jquery.com/jquery-latest.min.js"></script>
                          <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.2/dist/chart.umd.js"></script>
                          <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2"></script>
                          
                        <script src="http://code.jquery.com/jquery-latest.min.js"></script>
                        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.2/dist/chart.umd.js"></script>
                        <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2"></script>
                        
                        <script src="https://code.highcharts.com/highcharts.js"></script>
                        <script src="https://code.highcharts.com/modules/treemap.js"></script>
                        <script src="https://code.highcharts.com/modules/treegraph.js"></script>
                        <script src="https://code.highcharts.com/modules/exporting.js"></script> 
                        <script src="https://code.highcharts.com/modules/accessibility.js"></script>
                        <script src="https://code.highcharts.com/modules/drilldown.js"></script>
                        <script src="https://code.highcharts.com/modules/timeline.js"></script>
                        </head>
                    
                    
                  
                   
                    <p>Tra le testimonianze dell'archivio di <em>Voci dall'Inferno</em> è stata rinvenuta la presenza di tessere dantesche. Durante la fase di trascrizione e codifica, sono state individuate e distinte attraverso una opportuna codifica due tipi di citazioni: citazioni implicite e citazioni esplicite. Le prime riportano fedelmente determinati versi della Commedia, le seconde non riferiscono i versi esatti ma rimandano comunque ad un preciso passaggio presente in un canto. Inoltre, sono stati registrati anche casi in cuisono presenti allusioni, rimandi o riferimenti alla Commedia. Per alcuni è stato possibile identificare lo specifico canto in cui si ritrova un passaggio simile, per altri il riferimento avviene tramite l’uso di un vocabolo dantesco</p>
                    
                    <br/>
                    
                      <p>L'archivio digitale di <em>Voci dall'Inferno</em> è costituito da <b>{$num_archivio}</b> testimoni, per un totale di <b>{$num_testimonianze}</b> testimonianze.</p>
                      <br/>
                      <p>Ben <b>{$num_testimoni_con_dante}</b> testimoni su <b>{$num_archivio}</b> si servono del vocabolario dantesco per dire l'<em>ineffabile</em>: </p><br/>
                      <p>{for $t in $testimoni_con_dante 
                                    let $testimone_split := tokenize($t, "\s")
                                    let $linkAlTestimone := concat($testimone_split[2], " ", $testimone_split[1])
                                return <li id="t_dante"><a class="result_testimone" onclick='mostra_testimonianze("{$linkAlTestimone}")' >{($t)}</a></li>}</p>
                      
                  
                   
                   <h2 style="text-align:center; margin-top:15%;">Analisi sulle tessere dantesche</h2>
                   
                    <div id="cit">
                        
                    
                        <div id="intro_corpus_dante">
                    
                        <h3>Quante sono le tessere dantesche rinvenute nelle testimonianze dell'archivio?</h3>
                        <p>Dei <b>{$num_archivio}</b> testimoni totali che popolano l’archivio, <b>{$num_testimoni_con_dante}</b> fanno uso di citazioni o allusioni dantesche, per un totale di <b>{$tot_citazioni}</b> riferimenti alla <em>Commedia</em>, suddivisi come segue:</p>
                        
                        <br/>
                        <p>
                            <li><b>{count($num_citazioni_esplicite)}</b> citazioni esplicite</li>
                            <li><b>{count($num_citazioni_implicite)}</b> citazioni implicite</li>
                            <li><b>{count($num_riferimenti_dante)}</b> allusioni</li>
                            <li><b>{count($num_termini_dante)}</b> vocaboli danteschi</li>
                        </p>
                            
                        
                        </div>  
                        
                        <div id="ripartizione_dante">
                            <figure class="highcharts-figure2">
                                <div id="container2">
                                    <script>
                                        Highcharts.chart('container2', {{
                                                chart: {{
                                                    type: 'pie',
                                                    custom:{{}},
                                                    events:{{
                                                        render: function(){{
                                                            var chart = this;
                                                            var total = "Totale <br/> <em>tessere dantesche</em>:<br/> <b>{$tot_citazioni}</b>"; 
                                                            
                                                            if (chart.customLabel) {{
                                                                chart.customLabel.destroy();
                                                            }}
                                            
                                                            chart.customLabel = chart.renderer.text(
                                                                total, 
                                                                chart.plotWidth / 2 + chart.plotLeft, // Posizione X
                                                                chart.plotHeight / 2 + chart.plotTop // Posizione Y
                                                            ).css({{
                                                                color: '#000000', 
                                                                fontSize: '20px',
                                                                textAlign: 'center'
                                                            }}).attr({{
                                                                align: 'center',
                                                                zIndex: 5
                                                            }}).add();
                                                        
                                                        }}
                                                        
                                                    }}
                                                        
                                                }},
                                                accessibility: {{
                                                    point: {{
                                                        valueSuffix: ' '
                                                    }}
                                                }},
                                                title: {{
                                                    text: "In che modo Dante compare in <em>Voci dall'Inferno</em>?"
                                                }},
                                                
                                                tooltip: {{
                                                    pointFormat: '{{series.name}}: <b>{{point.y}}</b>'
                                                }},
                                                legend: {{
                                                    enabled: false
                                                }},
                                                plotOptions: {{
                                                    series: {{
                                                        allowPointSelect: true,
                                                        cursor: 'pointer',
                                                        borderRadius: 8,
                                                        dataLabels: [{{
                                                            enabled: true,
                                                            distance: 20,
                                                            format: '{{point.name}}',
                                                            style: {{
                                                                fontSize: '14px', // Aumenta la dimensione del font per il nome
                                                            }}
                                                        }}, {{
                                                            enabled: true,
                                                            distance: -15,
                                                            format: '{{point.y}}',
                                                            style: {{
                                                                fontSize: '0.9em'
                                                            }}
                                                        }}],
                                                        showInLegend: true
                                                    }}
                                                }},
                                                series: [{{
                                                    name: 'Totale',
                                                    colorByPoint: true,
                                                    innerSize: '75%',
                                                    data: [{{
                                                        name: 'Citazioni implicite',
                                                        y: {count($num_citazioni_implicite)}
                                                    }}, {{
                                                        name: 'Citazioni esplicite',
                                                        y: {count($num_citazioni_esplicite)}
                                                    }}, {{
                                                        name: 'Allusioni/riferimenti',
                                                        y: {count($num_riferimenti_dante)}
                                                    }}, {{
                                                        name:'Vocaboli danteschi',
                                                        y:{$tot_termini_danteschi}
                                                    }}]
                                                }}],
                                         
                                               
                                            }});
                                    </script>
                                </div>
                            </figure>
                        </div>
                    </div>
                    
                    
                    
                     <!--CANTICHE più citate-->
                    <div id="text" style="margin-left:3%;">
                        <!--<div id="num_cit">-->
                            <h3 style="text-align:center;">Da quale cantica provengono le <em>citazioni</em>?</h3>
                                <p>
                                    Dai dati emersi dall’archivio digitale di Voci dall’Inferno si osserva che la maggior parte delle citazioni, implicite ed esplicite, contenute all’interno delle testimonianze sono riconducibili alla prima cantica. Nonostante ciò, anche il Purgatorio e il Paradiso sono stati citati dai testimoni, seppur in misura minore.</p>
                                <br/>
                                <p>
                                    Rispetto alle cantiche della <em>Commedia</em>, le citazioni dantesche sono così ripartite:
                                    <li><b>Inferno</b>: {$tot_citazioni_inferno} citazioni</li>
                                    <li><b>Purgatorio</b>: {$tot_citazioni_purgatorio} citazioni</li>
                                    <li><b>Paradiso</b>: {$tot_citazioni_paradiso} citazioni</li>
                                </p>
                                

                
                        <figure class="highcharts-figure2">
                            <div id="container3">
                                <script>
                                   Highcharts.chart('container3', {{
                                  // Create the chart
                                        
                                            chart: {{
                                                type: 'column'
                                            }},
                                            title: {{
                                                align: 'center',
                                                text: 'Quale è la cantica a cui i testimoni fanno maggiore riferimento?'
                                            }},
                                             subtitle: {{
                                                align: 'center',
                                                text: "Clicca sulle colonne per vedere quali sono i canti più citati di ciascuna cantica",
                                            }},
                                            accessibility: {{
                                                announceNewData: {{
                                                    enabled: true
                                                }}
                                            }},
                                            xAxis: {{
                                                type: 'category'
                                            }},
                                            yAxis: {{
                                                title: {{
                                                    text: 'Totale occorrenze'
                                                }}
                                        
                                            }},
                                            legend: {{
                                                enabled: false
                                            }},
                                            plotOptions: {{
                                                series: {{
                                                    borderWidth: 0,
                                                    dataLabels: {{
                                                        enabled: true,
                                                        format: '{{point.y}}'
                                                    }}
                                                }}
                                            }},
                                        
                                            tooltip: {{
                                               
                                                valueSuffix: ' citazioni'
                                               
                                            }},
                                        
                                            series: [
                                                {{
                                                    name: 'Divina Commedia',
                                                    colorByPoint: true,
                                                    data: [
                                                        {{
                                                            name: 'Inferno',
                                                            y: {$tot_citazioni_inferno},
                                                            drilldown: 'Canti Inferno',
                                                            color: '#b91d47'
                                                        }},
                                                        {{
                                                            name: 'Purgatorio',
                                                            y: {$tot_citazioni_purgatorio},
                                                            drilldown: 'Canti Purgatorio',
                                                            color: '#00aba9'
                                                        }},
                                                        {{
                                                            name: 'Paradiso',
                                                            y: {$tot_citazioni_paradiso},
                                                            drilldown: 'Canti Paradiso',
                                                            color: '#2b5797'
                                                        }},
                                                        
                                                    ],
                                                     
                                                }}
                                            ],
                                            drilldown: {{
                                                breadcrumbs: {{
                                                    position: {{
                                                        align: 'right'
                                                    }}
                                                }},
                                                series: [
                                                    {{
                                                        name: 'Canti Inferno',
                                                        id: 'Canti Inferno',
                                                        data: {$occorrenze_canti_inferno_json_output}
                                                    }},
                                                    {{
                                                        name: 'Canti Purgatorio',
                                                        id: 'Canti Purgatorio',
                                                        data: {$occorrenze_canti_purgatorio_json_output}
                                                    }},
                                                    {{
                                                        name: 'Canti Paradiso',
                                                        id: 'Canti Paradiso',
                                                        data: {$occorrenze_canti_paradiso_json_output}
                                                    }},
                                                   
                                                ]
                                            }}
                                        }});
                                </script>
                            </div>
                        </figure>
                     
                    </div>     
                
                    <br style="margin-bottom:5%;"/>
                    
                    
                    <div id="text" style="margin-left:3%;">

                        <h3 style="text-align:center;">Quali sono i vocaboli danteschi presenti nelle testimonianze?</h3>
                            <p style="text-align:center; margin-bottom:2%;">Nelle testimonianze dell'archivio <em>Voci dall'Inferno</em> sono stati individuati <b>{$tot_termini_danteschi}</b> vocaboli danteschi.</p>
                            <br/>
                            
                             <figure class="highcharts-figure2">
                                <div id="container17">
                                    <script>
                                        Highcharts.chart('container17', {{
                                            chart: {{
                                                type: 'pie',
                                                custom: {{}},
                                                events: {{
                                                    render: function () {{
                                                        var chart = this;
                                                       var total =  "<em>Vocaboli <br/>danteschi</em>:<br/><b>{$tot_termini_danteschi}</b>";
                                                        
                                                        if (chart.customLabel) {{
                                                            chart.customLabel.destroy();
                                                        }}
                                        
                                                        chart.customLabel = chart.renderer.text(
                                                            total,
                                                            chart.plotWidth / 2 + chart.plotLeft, // Posizione X
                                                            chart.plotHeight / 2 + chart.plotTop // Posizione Y
                                                        ).css({{
                                                            color: '#000000',
                                                            fontSize: '20px',
                                                            textAlign: 'center'
                                                        }}).attr({{
                                                            align: 'center',
                                                            zIndex: 5
                                                        }}).add();
                                                    }}
                                                }}
                                            }},
                                            accessibility: {{
                                                point: {{
                                                    valueSuffix: ' '
                                                }}
                                            }},
                                            title: {{
                                                text: "<em>Vocaboli danteschi</em> nelle testimonianze di <em>Voci dall'Inferno</em>"
                                            }},
                                            tooltip: {{
                                                pointFormat: '{{series.name}}: <b>{{point.y}}</b>'
                                            }},
                                            legend: {{
                                                enabled: true
                                            }},
                                            plotOptions: {{
                                                series: {{
                                                    allowPointSelect: true,
                                                    cursor: 'pointer',
                                                    borderRadius: 8,
                                                    dataLabels: [{{
                                                        enabled: true,
                                                        distance: 20,
                                                        format: '{{point.name}}',
                                                        style: {{
                                                            fontSize: '14px',
                                                        }}
                                                    }}, {{
                                                        enabled: true,
                                                        distance: -15,
                                                        format: '{{point.y}}',
                                                        style: {{
                                                            fontSize: '0.9em'
                                                        }}
                                                    }}],
                                                    showInLegend: true
                                                }}
                                            }},
                                            series: [{{
                                                name: 'occorrenze',
                                                colorByPoint: true,
                                                innerSize: '75%',
                                                data: {$termini_dante_output_json}
                                            }}]
                                        }});
                                    </script>
                                </div>
                            </figure>
                    </div>
                    
                    
                    
                    <h2 style="text-align:center; margin-top:15%;">Analisi sui testimoni che ricorrono al lessico dantesco</h2>
                    
                    
                    <p style="margin-top:3%;text-align:center;"> Nelle testimonianze del corpus sono state identificati <b>{$tot_citazioni}</b> riferimenti alla <em>Commedia</em>. <br/>
                    I testimoni che utilizzano le parole di Dante per dire l'<em>ineffabile</em> sono <b>{$num_testimoni_con_dante}</b> su <b>{$num_archivio}</b>. </p>
                   
                       
                    <!--chi fa più CITAZIONI-->
                    <div id="cit">
                        <div id="num_cit">
                            <h3>Quale testimone cita maggiormente la <em>Divina Commedia</em>?</h3>
                           <p>Di seguito sono riportati i nomi di coloro che ricorrono al lessico dantesco e quante volte esso occorre nelle loro testimonianze: </p>
                           <br/>
                            <p>{for $i in $testimoni_con_dante return <li>{$i}</li>}</p>
                        </div>
                        
                        <div id="ripartizione_dante">
                            <figure class="highcharts-figure2">
                                <div id="container11">
                                    <script>
                                        Highcharts.chart('container11', {{
                                            chart: {{
                                                type: 'pie',
                                                custom: {{}},
                                                events: {{
                                                    render: function () {{
                                                        var chart = this;
                                                       var total =  "Totale <br/><em>tessere<br/> dantesche</em>: <br/><b>{$tot_citazioni}</b>";
                                                        
                                                        if (chart.customLabel) {{
                                                            chart.customLabel.destroy();
                                                        }}
                                        
                                                        chart.customLabel = chart.renderer.text(
                                                            total,
                                                            chart.plotWidth / 2 + chart.plotLeft, // Posizione X
                                                            chart.plotHeight / 2 + chart.plotTop // Posizione Y
                                                        ).css({{
                                                            color: '#000000',
                                                            fontSize: '20px',
                                                            textAlign: 'center'
                                                        }}).attr({{
                                                            align: 'center',
                                                            zIndex: 5
                                                        }}).add();
                                                    }}
                                                }}
                                            }},
                                            accessibility: {{
                                                point: {{
                                                    valueSuffix: ' '
                                                }}
                                            }},
                                            title: {{
                                                text: "In quale testimone ricorre maggiormente la Commedia?"
                                            }},
                                            tooltip: {{
                                                pointFormat: '{{series.name}}: <b>{{point.y}}</b>'
                                            }},
                                            legend: {{
                                                enabled: true
                                            }},
                                            plotOptions: {{
                                                series: {{
                                                    allowPointSelect: true,
                                                    cursor: 'pointer',
                                                    borderRadius: 8,
                                                    dataLabels: [{{
                                                        enabled: true,
                                                        distance: 20,
                                                        format: '{{point.name}}',
                                                        style: {{
                                                            fontSize: '14px',
                                                        }}
                                                    }}, {{
                                                        enabled: true,
                                                        distance: -15,
                                                        format: '{{point.y}}',
                                                        style: {{
                                                            fontSize: '0.9em'
                                                        }}
                                                    }}],
                                                    showInLegend: true
                                                }}
                                            }},
                                            series: [{{
                                                name: 'Totale tessere dantesche',
                                                colorByPoint: true,
                                                innerSize: '75%',
                                                data: {$dante_testimone_json_output}
                                            }}]
                                        }});
                                    </script>
                                </div>
                            </figure>
                        </div>
                    </div> 
                    
                        
                    
                    <!--ANALISI CITAZIONI ESPLICITE-->
                    <h2 style="text-align:center;margin-top:5%;">Quali testimoni citano in forma <em>esplicita</em>?</h2>
                    <div id="cit">
                        <div id="num_cit">
                            <p>Coloro che riportano fedelmente in maniera esplicita i versi della <em>Divina Commedia</em> sono: {for $x in $esplicite_per_testimone return <li>{$x}</li>}  </p>
                            <br/>
                            <p>Nel grafico a fianco è mostrato il numero di occorrenze di citazioni esplicite per ciascun testimone.</p>
                            <br/>
                             <p>Rispetto alle tre cantiche, le citazioni esplicite sono ripartite come segue:
                                <li><b>Inferno</b>: {$inferno_count_esplicite}</li>
                                <li><b>Purgatorio</b>: {$purgatorio_count_esplicite}</li>
                                <li><b>Paradiso</b>: {$paradiso_count_esplicite}</li>
                            </p>
                        </div>
                        
                         <div id="ripartizione_dante">
                            <figure class="highcharts-figure2">
                                <div id="container9">
                                    <script>
                                        Highcharts.chart('container9', {{
                                            chart: {{
                                                type: 'pie',
                                                custom: {{}},
                                                events: {{
                                                    render: function () {{
                                                        var chart = this;
                                                       var total =  "Citazioni esplicite: <br/><b>{count($num_citazioni_esplicite)}</b>";
                                                        
                                                        if (chart.customLabel) {{
                                                            chart.customLabel.destroy();
                                                        }}
                                        
                                                        chart.customLabel = chart.renderer.text(
                                                            total,
                                                            chart.plotWidth / 2 + chart.plotLeft, // Posizione X
                                                            chart.plotHeight / 2 + chart.plotTop // Posizione Y
                                                        ).css({{
                                                            color: '#000000',
                                                            fontSize: '20px',
                                                            textAlign: 'center'
                                                        }}).attr({{
                                                            align: 'center',
                                                            zIndex: 5
                                                        }}).add();
                                                    }}
                                                }}
                                            }},
                                            accessibility: {{
                                                point: {{
                                                    valueSuffix: ' '
                                                }}
                                            }},
                                            title: {{
                                                text: "Citazioni <em>esplicite</em> per testimone in <em>Voci dall'Inferno</em>"
                                            }},
                                            tooltip: {{
                                                pointFormat: '{{series.name}}: <b>{{point.y}}</b>'
                                            }},
                                            legend: {{
                                                enabled: true
                                            }},
                                            plotOptions: {{
                                                series: {{
                                                    allowPointSelect: true,
                                                    cursor: 'pointer',
                                                    borderRadius: 8,
                                                    dataLabels: [{{
                                                        enabled: true,
                                                        distance: 20,
                                                        format: '{{point.name}}',
                                                        style: {{
                                                            fontSize: '14px',
                                                        }}
                                                    }}, {{
                                                        enabled: true,
                                                        distance: -15,
                                                        format: '{{point.y}}',
                                                        style: {{
                                                            fontSize: '0.9em'
                                                        }}
                                                    }}],
                                                    showInLegend: true
                                                }}
                                            }},
                                            series: [{{
                                                name: 'Citazioni esplicite',
                                                colorByPoint: true,
                                                innerSize: '75%',
                                                data: {$cit_esplicite_json_output}
                                            }}]
                                        }});
                                    </script>
                                </div>
                            </figure>
                        </div>
                    </div>
                        
                        
                    <!--tabella citazioni esplicite-->        
                    <div id="cit_esplicite" style="margin-top:5%;text-align:center;">
                         <p>In tabella sono riportate le citazioni esplicite identificate nelle testimonianze di <em>Voci dall'Inferno</em>, suddivise per testimone, cantica e canto. </p>
                         <br/>
                         <div id="tabella_citazioni" class="section_tabella">
                                    <table class="tabella">
                                      <tr>
                                        <th>Cantica</th>
                                        <th>Canto</th>
                                        <th>Testimone</th>
                                        <th>Titolo testimonianza</th>
                                        <th>Citazione esplicita</th>
                                      </tr>
                                      { 
                                        
                                        for $xml in $xmlCollection/*
                                        
                                        let $citazioni_esplicite:=$xml//tei:text//tei:cit[@type="explicit"]
                                        let $lista_testimoni:=concat($xml//tei:person[@role="testimone"]/tei:persName/tei:forename, " ",$xml//tei:person[@role="testimone"]/tei:persName/tei:surname[1])
                                        
                                        for $cit in $citazioni_esplicite
                                        
                                            let $target := $cit/tei:ref/@target/string()
                                            
                                            
                                            for $t in $target
                                                let $target_tokenize := tokenize($t, "#")[2]
                                                
                                                (: risalgo al <biblStruct> che abbia xml:id uguale al valore target del <ref> :)
                                                let $bibl := $xml//tei:standOff//tei:listBibl//tei:biblStruct[@xml:id = $target_tokenize]
                                                let $xml:id:=$bibl/@xml:id/string()
                                                let $cantica := $bibl//tei:monogr//tei:title[@level="m"]/string()
                                                let $canto:=$bibl//tei:analytic//tei:title[@level="a"]/string()
                                                let $titolo_testimonianza:=$xml//tei:title[@xml:id="titolotestimonianza"]/string()
                                                
                                                let $occorrenze := count($xml//tei:standOff//tei:listBibl//tei:biblStruct[@xml:id = $target_tokenize])
                                                
                                                (: conto le occorrenze delle varie cantiche per ordinarle in modo decrescente :)
                                                let $occorrenze_inf:= count($bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Inferno")])
                                                let $occorrenze_pur:=count($bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Purgatorio")])
                                                let $occorrenze_par:= count($bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Paradiso")]) 
                                                
                                                
                                                   
                                                (: Ordino secondo Inferno-Purgatorio-Paradiso :)
                                                order by 
                                                    $occorrenze_inf descending,
                                                    $occorrenze_pur descending,
                                                    $occorrenze_par descending
                                                                        
                                            
          
                                        return 
                                        
                                        <tr>
                                            <td>{$cantica}</td>
                                            <td>{$canto}</td>
                                            <td>{for $l in $lista_testimoni
                                                return $l} </td>
                                            <td><em>{$titolo_testimonianza}</em></td>
                                            <td><em>{$cit}</em></td>
                                        </tr>
                                        
                                      }
                                    </table>
                            </div>
                    </div>
                    
                     <!--ANALISI CITAZIONI IMPLICITE-->
                    <h2 style="text-align:center;margin-top:5%;">Quali testimoni citano in forma <em>implicita</em>?</h2>
                    <div id="cit">
                        <div id="num_cit">
                            <p>Coloro che riportano in forma implicita i versi della <em>Divina Commedia</em> sono: {for $x in $implicite_per_testimone return <li>{$x}</li>}  </p>
                            <br/>
                            <p>Nel grafico a fianco è mostrato il numero di occorrenze di citazioni implicite per ciascun testimone.</p>
                            <br/>
                             <p>Rispetto alle tre cantiche, le citazioni implicite sono ripartite come segue:
                                <li><b>Inferno</b>: {$inferno_count_implicite}</li>
                                <li><b>Purgatorio</b>: {$purgatorio_count_implicite}</li>
                                <li><b>Paradiso</b>: {$paradiso_count_implicite}</li>
                            </p>
                        </div>
                    
                        <div id="ripartizione_dante">
                            <figure class="highcharts-figure2">
                                <div id="container10">
                                    <script>
                                        Highcharts.chart('container10', {{
                                            chart: {{
                                                type: 'pie',
                                                custom: {{}},
                                                events: {{
                                                    render: function () {{
                                                        var chart = this;
                                                        var total =  "Citazioni implicite: <br/><b>{count($num_citazioni_implicite)}</b>";
                                                        
                                                        if (chart.customLabel) {{
                                                            chart.customLabel.destroy();
                                                        }}
                                        
                                                        chart.customLabel = chart.renderer.text(
                                                            total,
                                                            chart.plotWidth / 2 + chart.plotLeft, // Posizione X
                                                            chart.plotHeight / 2 + chart.plotTop // Posizione Y
                                                        ).css({{
                                                            color: '#000000',
                                                            fontSize: '20px',
                                                            textAlign: 'center'
                                                        }}).attr({{
                                                            align: 'center',
                                                            zIndex: 5
                                                        }}).add();
                                                    }}
                                                }}
                                            }},
                                            accessibility: {{
                                                point: {{
                                                    valueSuffix: ' '
                                                }}
                                            }},
                                            title: {{
                                                text: "Citazioni <em>implicite</em> per testimone in <em>Voci dall'Inferno</em>"
                                            }},
                                            tooltip: {{
                                                pointFormat: '{{series.name}}: <b>{{point.y}}</b>'
                                            }},
                                            legend: {{
                                                enabled: true
                                            }},
                                            plotOptions: {{
                                                series: {{
                                                    allowPointSelect: true,
                                                    cursor: 'pointer',
                                                    borderRadius: 8,
                                                    dataLabels: [{{
                                                        enabled: true,
                                                        distance: 20,
                                                        format: '{{point.name}}',
                                                        style: {{
                                                            fontSize: '14px',
                                                        }}
                                                    }}, {{
                                                        enabled: true,
                                                        distance: -15,
                                                        format: '{{point.y}}',
                                                        style: {{
                                                            fontSize: '0.9em'
                                                        }}
                                                    }}],
                                                    showInLegend: true
                                                }}
                                            }},
                                            series: [{{
                                                name: 'Citazioni implicite',
                                                colorByPoint: true,
                                                innerSize: '75%',
                                                data: {$cit_implicite_json_output}
                                            }}]
                                        }});
                                    </script>
                                </div>
                            </figure>
                        </div>
                    </div>
                    
                    
                    
                   
                    <!--TABELLE citazioni e riferimenti-->
                    <div id="cit_implicite" style="margin-top:30px;text-align:center;">
                                <p>In tabella sono riportate le citazioni implicite identificate nelle testimonianze di <em>Voci dall'Inferno</em>, suddivise per testimone, cantica e canto. </p>
                                <br/>
                                <div id="tabella_citazioni" class="section_tabella">
                                    
                                    <table class="tabella">
                                      <tr>
                                        <th>Cantica</th>
                                        <th>Canto</th>
                                        <th>Testimone</th>
                                        <th>Titolo testimonianza</th>
                                        <th>Citazione implicita</th>
                                      </tr>
                                      { 
                                        
                                        for $xml in $xmlCollection/*
                                        
                                        let $citazioni_implicite:=$xml//tei:text//tei:cit[@type="implicit"]
                                        let $lista_testimoni:=concat($xml//tei:person[@role="testimone"]/tei:persName/tei:forename, " ",$xml//tei:person[@role="testimone"]/tei:persName/tei:surname[1])
                                        
                                        for $cit in $citazioni_implicite
                                        
                                            let $target := $cit/tei:ref/@target/string()
                                            for $t in $target
                                                let $target_tokenize := tokenize($t, "#")[2]
                                                
                                                (: risalgo al <biblStruct> che abbia xml:id uguale al valore target del <ref> :)
                                                let $bibl := $xml//tei:standOff//tei:listBibl//tei:biblStruct[@xml:id = $target_tokenize]
                                                (:  :let $xml:id:=$bibl/@xml:id/string():)
                                                let $cantica := $bibl//tei:monogr//tei:title[@level="m"]/string()
                                                let $canto:=$bibl//tei:analytic//tei:title[@level="a"]/string()
                                                let $titolo_testimonianza:=$xml//tei:title[@xml:id="titolotestimonianza"]/string()
                                                
                                                
                                                (: conto le occorrenze delle varie cantiche per ordinarle in modo decrescente :)
                                                let $occorrenze_inf:= count($bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Inferno")])
                                                let $occorrenze_pur:=count($bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Purgatorio")])
                                                let $occorrenze_par:= count($bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Paradiso")])
                                                
                                                
                                                (: Ordino secondo Inferno-Purgatorio-Paradiso :)
                                                order by 
                                                    $occorrenze_inf descending,
                                                    $occorrenze_pur descending,
                                                    $occorrenze_par descending
                            
                                            
                                        return
                                          
                                        
                                        <tr>
                                            <td>{$cantica}</td>
                                            <td>{$canto}</td>
                                              <td>{for $l in $lista_testimoni
                                                return $l}</td>
                                            <td><em>{$titolo_testimonianza}</em></td>
                                            <td><em>{$cit}</em></td>
                                        </tr>
                                      }
                                    </table>
                                    
                                </div>
                       
                    </div>
                    
                    
                    
                    <!--ANALISI ALLUSIONI/RIFERIMENTI-->
                    
                    <h2 style="text-align:center;margin-top:5%;">Quali testimoni ricorrono ad <em>allusioni</em> o <em>riferimenti</em> alla <em>Commedia</em>?</h2>
                    <div id="cit">
                        <div id="num_cit">
                            <p>Coloro che ricorrono ad allusioni o riferimenti alla <em>Divina Commedia</em> sono: {for $x in $allusioni_per_testimone_names return <li>{$x}</li>}  </p>
                            <br/>
                            <p>Nel grafico a fianco è mostrato il numero di ciascuno di essi per ciascun testimone.</p>
                            <br/>
                             <p>Rispetto alle tre cantiche, le allusioni sono ripartite come segue:
                                <li><b>Inferno</b>: {$inferno_count_allusioni}</li>
                                <li><b>Purgatorio</b>: {$purgatorio_count_allusioni}</li>
                                <li><b>Paradiso</b>: {$paradiso_count_allusioni}</li>
                            </p>
                        </div>
                        
                        
                         <div id="ripartizione_dante">
                            <figure class="highcharts-figure2">
                                <div id="container15">
                                
                                    <script>
                                        Highcharts.chart('container15', {{
                                            chart: {{
                                                type: 'pie',
                                                custom: {{}},
                                                events: {{
                                                    render: function () {{
                                                        var chart = this;
                                                       var total =  "Totale allusioni:<br/><b>{count($num_riferimenti_dante)}</b>";
                                                        
                                                        if (chart.customLabel) {{
                                                            chart.customLabel.destroy();
                                                        }}
                                        
                                                        chart.customLabel = chart.renderer.text(
                                                            total,
                                                            chart.plotWidth / 2 + chart.plotLeft, // Posizione X
                                                            chart.plotHeight / 2 + chart.plotTop // Posizione Y
                                                        ).css({{
                                                            color: '#000000',
                                                            fontSize: '20px',
                                                            textAlign: 'center'
                                                        }}).attr({{
                                                            align: 'center',
                                                            zIndex: 5
                                                        }}).add();
                                                    }}
                                                }}
                                            }},
                                            accessibility: {{
                                                point: {{
                                                    valueSuffix: ' '
                                                }}
                                            }},
                                            title: {{
                                                text: "<em>Allusioni/riferimenti</em> per testimone in <em>Voci dall'Inferno</em>"
                                            }},
                                            tooltip: {{
                                                pointFormat: '{{series.name}}: <b>{{point.y}}</b>'
                                            }},
                                            legend: {{
                                                enabled: true
                                            }},
                                            plotOptions: {{
                                                series: {{
                                                    allowPointSelect: true,
                                                    cursor: 'pointer',
                                                    borderRadius: 8,
                                                    dataLabels: [{{
                                                        enabled: true,
                                                        distance: 20,
                                                        format: '{{point.name}}',
                                                        style: {{
                                                            fontSize: '14px',
                                                        }}
                                                    }}, {{
                                                        enabled: true,
                                                        distance: -15,
                                                        format: '{{point.y}}',
                                                        style: {{
                                                            fontSize: '0.9em'
                                                        }}
                                                    }}],
                                                    showInLegend: true
                                                }}
                                            }},
                                            series: [{{
                                                name: 'Allusioni',
                                                colorByPoint: true,
                                                innerSize: '75%',
                                                data: {$allusioni_json_output}
                                            }}]
                                        }});
                                    </script>
                                
                                </div>
                            </figure>
                        </div>
                    </div>
                    
                    
                     <!--TABELLA ALLUSIONI-->
                    <div id="cit_implicite" style="margin-top:30px;text-align:center;">
                                <p>In tabella sono riportate le allusioni identificate nelle testimonianze di <em>Voci dall'Inferno</em>, suddivise per testimone e cantica. </p>
                                <br/>
                                <div id="tabella_citazioni" class="section_tabella">
                                    
                                    <table class="tabella">
                                      <tr>
                                        <th>Cantica</th>
                                        <th>Testimone</th>
                                        <th>Titolo testimonianza</th>
                                        <th>Allusione</th>
                                      </tr>
                                      { 
                                        
                                        for $xml in $xmlCollection/*
                                        
                                        let $allusioni:=$xml//tei:text//tei:ref[@type="allusion"]
                                        let $lista_testimoni:=concat($xml//tei:person[@role="testimone"]/tei:persName/tei:forename, " ",$xml//tei:person[@role="testimone"]/tei:persName/tei:surname[1])
                                        
                                        for $ref in $allusioni
                                        
                                            let $target := $ref/@target/string()
                                            for $t in $target
                                                let $target_tokenize := tokenize($t, "#")[2]
                                                
                                                (: risalgo al <biblStruct> che abbia xml:id uguale al valore target del <ref> :)
                                                let $bibl := $xml//tei:standOff//tei:listBibl//tei:biblStruct[@xml:id = $target_tokenize]
                                                (:  :let $xml:id:=$bibl/@xml:id/string():)
                                                let $cantica := $bibl//tei:monogr//tei:title[@level="m"]/string()
                                                (:  :let $canto:=$bibl//tei:analytic//tei:title[@level="a"]/string():)
                                                let $titolo_testimonianza:=$xml//tei:title[@xml:id="titolotestimonianza"]/string()
                                                
                                                
                                                (: conto le occorrenze delle varie cantiche per ordinarle in modo decrescente :)
                                                let $occorrenze_inf:= count($bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Inferno")])
                                                let $occorrenze_pur:=count($bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Purgatorio")])
                                                let $occorrenze_par:= count($bibl//tei:monogr//tei:title[@level="m" and contains(normalize-space(.), "Paradiso")])
                                                
                                                
                                                (: Ordino secondo Inferno-Purgatorio-Paradiso :)
                                                order by 
                                                    $occorrenze_inf descending,
                                                    $occorrenze_pur descending,
                                                    $occorrenze_par descending
                            
                                            
                                        return
                                          
                                        
                                        <tr>
                                            <td>{$cantica}</td>
                                            <td>{for $l in $lista_testimoni
                                                return $l}</td>
                                            <td><em>{$titolo_testimonianza}</em></td>
                                            <td><em>{$ref}</em></td>
                                        </tr>
                                      }
                                    </table>
                                    
                                </div>
                       
                    </div>
                    
                    
                    
                    <h2 style="text-align:center;margin-top:5%;">Quali testimoni utilizzano <em>vocaboli</em> danteschi?</h2>
                    <div id="cit">
                        <div id="num_cit">
                            <p>Coloro che utilizzano termini danteschi  sono: {for $x in $termini_per_testimone_names return <li>{$x}</li>}  </p>
                            <br/>
                            <p>Nel grafico a fianco è mostrato il numero di ciascuno di essi per ciascun testimone.</p>
                        </div>
                        
                        
                         <div id="ripartizione_dante">
                            <figure class="highcharts-figure2">
                                <div id="container16">
                                    <script>
                                        Highcharts.chart('container16', {{
                                            chart: {{
                                                type: 'pie',
                                                custom: {{}},
                                                events: {{
                                                    render: function () {{
                                                        var chart = this;
                                                       var total =  "Totale termini <br/>danteschi:<br/><b>{$tot_termini_danteschi}</b>";
                                                        
                                                        if (chart.customLabel) {{
                                                            chart.customLabel.destroy();
                                                        }}
                                        
                                                        chart.customLabel = chart.renderer.text(
                                                            total,
                                                            chart.plotWidth / 2 + chart.plotLeft, // Posizione X
                                                            chart.plotHeight / 2 + chart.plotTop // Posizione Y
                                                        ).css({{
                                                            color: '#000000',
                                                            fontSize: '20px',
                                                            textAlign: 'center'
                                                        }}).attr({{
                                                            align: 'center',
                                                            zIndex: 5
                                                        }}).add();
                                                    }}
                                                }}
                                            }},
                                            accessibility: {{
                                                point: {{
                                                    valueSuffix: ' '
                                                }}
                                            }},
                                            title: {{
                                                text: "<em>Vocaboli danteschi</em> per testimone in <em>Voci dall'Inferno</em>"
                                            }},
                                            tooltip: {{
                                                pointFormat: '{{series.name}}: <b>{{point.y}}</b>'
                                            }},
                                            legend: {{
                                                enabled: true
                                            }},
                                            plotOptions: {{
                                                series: {{
                                                    allowPointSelect: true,
                                                    cursor: 'pointer',
                                                    borderRadius: 8,
                                                    dataLabels: [{{
                                                        enabled: true,
                                                        distance: 20,
                                                        format: '{{point.name}}',
                                                        style: {{
                                                            fontSize: '14px',
                                                        }}
                                                    }}, {{
                                                        enabled: true,
                                                        distance: -15,
                                                        format: '{{point.y}}',
                                                        style: {{
                                                            fontSize: '0.9em'
                                                        }}
                                                    }}],
                                                    showInLegend: true
                                                }}
                                            }},
                                            series: [{{
                                                name: 'Vocaboli danteschi',
                                                colorByPoint: true,
                                                innerSize: '75%',
                                                data: {$termini_json_output}
                                            }}]
                                        }});
                                    </script>
                                </div>
                            </figure>
                        </div>
                    </div>
                    
                     
                    
                     <div id="riferimenti"style="margin-top:30px;text-align:center;">
                        <p>In tabella sono riportati i termini danteschi identificati nelle testimonianze di <em>Voci dall'Inferno</em> e suddivisi per testimone.
                        </p>
                        <br/>
                         <div id="tabella_citazioni" class="section_tabella">
                        
                                    <table class="tabella">
                                      <tr>
                                        <th>Testimone</th>
                                        <th>Titolo testimonianza</th>
                                        <th>Vocaboli danteschi</th>
                                      </tr>
                                      { 
                                        
                                        for $xml in $xmlCollection/*
                                        let $testimone_nome := concat($xml//tei:person[@role="testimone"]/tei:persName/tei:forename, " ", $xml//tei:person[@role="testimone"]/tei:persName/tei:surname[1])
                                        let $titolo_testimonianza := $xml//tei:title[@xml:id="titolotestimonianza"]/string()
                                        
                                        (: Colleziono tutti i vocaboli danteschi :)
                                        let $vocaboli_dante := 
                                          for $v in $xml//tei:text//tei:term[@type="dante"]
                                          let $ref := $v/@ref/string()
                                          for $r in $ref
                                          let $ref_tokenize := tokenize($r, "#")[2]
                                          let $item := $xml//tei:standOff//tei:list[@xml:id="listaTerminiDante"]//tei:item[@xml:id = $ref_tokenize]
                                          return $v/string()
                                                
                                        let $num_occorrenze := count($vocaboli_dante)
                                         where $num_occorrenze > 0
                                         order by $num_occorrenze descending
                                          
                                        return
                                          
                                            <tr>
                                                <td>{$testimone_nome}</td>
                                                <td><em>{$titolo_testimonianza}</em></td>
                                               <td>{string-join($vocaboli_dante, ", ")}</td>
                                            </tr>
                                       
                                      }
                                    </table>
                                    
                            </div>
                         
                         
                         
                      
                        
                    </div>
                    
                    
                    
                   
                </div>
        
    
            
};




declare function app:statistiche_corpus($node as node(), $model as map(*)){
    
    let $xmlCollection:=collection("/db/apps/voci_inferno/xml")
    
    (: conto il numero totale di testimoni presenti nell'archivio :)
    let $num_archivio:=local:contaTestimoniCollezione("/db/apps/voci_inferno/xml")-1
    
    
    (: conto num ebrei :)
    let $num_deportati_ebrei:=local:contaTestimoniCollezione("/db/apps/voci_inferno/xml/Deportati/Ebrei")
    
    (: conto num IMI :)
    let $num_deportati_IMI:=local:contaTestimoniCollezione("/db/apps/voci_inferno/xml/Deportati/I.M.I")
    
    (: conto num non deportati :)
    let $num_non_deportati_partigiani_ebrei:=local:contaTestimoniCollezione("/db/apps/voci_inferno/xml/NonDeportati/PartigianiEbrei")
    
    (: conto quante sono le testimonianze totali:)
    let $titoli := 
        for $xml in $xmlCollection/*
        let $find_testimone := $xml//tei:person[@role="testimone"]
        (:  :let $nome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:forename)
        let $cognome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:surname)
        
        where $cognome_testimone = $testimone_split[1] and $nome_testimone = $testimone_split[2] :)
        for $titolo in $xml//tei:title[@xml:id="titolotestimonianza"]
        return fn:normalize-space(string($titolo))
        
    let $num_testimonianze :=count($titoli)  
    

    
    

    (: conto numero testimonianze orali :)
    let $num_testimonianze_orali :=
        count(
            for $xml in $xmlCollection/*
            where exists($xml//tei:recordingStmt)
            return $xml
        )

        
     (: conto numero testimonianze scritte :)
    let $num_testimonianze_scritte :=
        count(
            for $xml in $xmlCollection/*
            where exists($xml//tei:objectDesc)
            return $xml
        )


    (: Conto numero testimonianze video :)
    let $num_testimonianze_video :=
        count(
            for $xml in $xmlCollection/*
            where exists($xml//tei:recordingStmt/tei:recording[@type="video"])
            return $xml
        )

    (: Conto numero testimonianze audio :)
    let $num_testimonianze_audio :=
        count(
            for $xml in $xmlCollection/*
            where exists($xml//tei:recordingStmt/tei:recording[@type="audio"])
            return $xml
        )
        
    (: Conto numero diari :)
    let $num_testimonianze_diari :=
        count(
            for $xml in $xmlCollection/*
            where exists($xml//tei:objectDesc[@form="manuscript_diary"])
            return $xml
        )
        
    (: Conto numero lettere :)
    let $num_testimonianze_lettere :=
        count(
            for $xml in $xmlCollection/*
            where exists($xml//tei:objectDesc[@form="letters"])
            return $xml
        )
        
    (: Conto numero fogli manoscritti :)
    let $num_testimonianze_fogli_manoscritti :=
        count(
            for $xml in $xmlCollection/*
            where exists($xml//tei:objectDesc[@form="manuscript_sheet"])
            return $xml
        )
        
    (: Conto numero fascicoli :)
    let $num_testimonianze_fascicoli :=
        count(
            for $xml in $xmlCollection/*
            where exists($xml//tei:objectDesc[@form="dossier"])
            return $xml
        )
        
        
    let $num_pagine_trascritte:=
        count(
            for $xml in $xmlCollection/*
            where exists($xml//tei:physDesc/tei:objectDesc)
            let $pagina:=$xml//tei:surface
            return $pagina
        )
    
        
    
    (: calcolo ore di registrazione trascritte :)    
    let $durate :=
        for $xml in $xmlCollection/*
        where exists($xml//tei:sourceDesc/tei:recordingStmt)
        let $dur_list := $xml//tei:recordingStmt//tei:recording/@dur
    
        for $durata in $dur_list
        let $durata-in-secondi := xs:duration($durata)
        let $ore := hours-from-duration($durata-in-secondi)
        let $minuti := minutes-from-duration($durata-in-secondi)
        let $secondi := seconds-from-duration($durata-in-secondi)

    return ($ore, $minuti, $secondi)

    let $total-ore := sum(for $d in $durate[position() mod 3 = 1] return $d)
    let $total-minuti := sum(for $d in $durate[position() mod 3 = 2] return $d)
    let $total-secondi := sum(for $d in $durate[position() mod 3 = 0] return $d)
    
    let $extra-minuti := floor($total-secondi div 60)
    let $remaining-secondi := $total-secondi mod 60
    
    let $total-minuti := $total-minuti + $extra-minuti
    let $extra-ore := floor($total-minuti div 60)
    let $remaining-minuti := $total-minuti mod 60
    
    let $total-ore := $total-ore + $extra-ore
    
    let $num_ore_trascritte:=concat($total-ore, " ore, ", $remaining-minuti, " minuti e ", $remaining-secondi, " secondi")

        

  
  
    
    (: calcolo ore trascritte del fondo pavoncello-segre :)
    let $durate_anna_segre :=
        for $xml in $xmlCollection/*
        where exists($xml//tei:sourceDesc/tei:recordingStmt)
            and data($xml//tei:broadcast//tei:author[1]) = "Anna Segre"
        let $dur_list := $xml//tei:recordingStmt//tei:recording/@dur
        
        for $durata in $dur_list
        let $durata-in-secondi := xs:duration($durata)
        let $ore := hours-from-duration($durata-in-secondi)
        let $minuti := minutes-from-duration($durata-in-secondi)
        let $secondi := seconds-from-duration($durata-in-secondi)
    
        return ($ore, $minuti, $secondi)
    
    let $total-ore-anna := sum(for $d in $durate_anna_segre[position() mod 3 = 1] return $d)
    let $total-minuti-anna := sum(for $d in $durate_anna_segre[position() mod 3 = 2] return $d)
    let $total-secondi-anna := sum(for $d in $durate_anna_segre[position() mod 3 = 0] return $d)
    
    let $extra-minuti-anna := floor($total-secondi-anna div 60)
    let $remaining-secondi-anna := $total-secondi-anna mod 60
    
    let $total-minuti-anna := $total-minuti-anna + $extra-minuti-anna
    let $extra-ore-anna := floor($total-minuti-anna div 60)
    let $remaining-minuti-anna := $total-minuti-anna mod 60
    
    let $total-ore-anna := $total-ore-anna + $extra-ore-anna
    
    let $num_ore_trascritte_anna := concat($total-ore-anna, " ore, ", $remaining-minuti-anna, " minuti e ", $remaining-secondi-anna, " secondi")

        
    

   
    
    
    
    (:conto quante testimonianze orali provengono da ciascuna fonte. Es: numero testimonianze appartenenti al fondo pavoncello-segre :)
    let $lista_authors:=
        for $xml in $xmlCollection/*
        where exists($xml//tei:sourceDesc/tei:recordingStmt)
        let $author:=distinct-values($xml//tei:broadcast//tei:author[1])
        return $author
    
    
    let $occorrenze_authors:=
        for $author in distinct-values($lista_authors)
            let $occorrenze:=count($lista_authors[.=$author])
            order by $occorrenze descending
            
            return  concat('{"name": "', $author, '", "y": ', $occorrenze, '}')  
     
    let $occorrenze_authors_json_output :=  '[' || string-join($occorrenze_authors, ', ') || ']'
    
    
          
        
    
    
    
    (:conto quante testimonianze scritte provengono da ciascuna fonte. Es: CDEC o collezioni private :)
    let $lista_repository:=
        for $xml in $xmlCollection/*
        where exists($xml//tei:objectDesc)
        let $repo:=distinct-values($xml//tei:sourceDesc//tei:msIdentifier//tei:repository)
        return $repo
        
    let $occorrenze_repo:=
        for $repo in distinct-values($lista_repository)
            let $occorrenze:=count($lista_repository[.=$repo])
            order by $occorrenze descending
            
            return  concat('{"name": "', $repo, '", "y": ', $occorrenze, '}')  
    
    let $occorrenze_repo_json_output :=  '[' || string-join($occorrenze_repo, ', ') || ']'
            

 
    
    let $collezione:=
        if ($xmlCollection="deportati") then
            let $path:="/db/apps/voci_inferno/xml/Deportati"
            return $path
        else 
            let $path:="/db/apps/voci_inferno/xml/NonDeportati"
            return $path
            
    let $testimoni:=
        for $xml in collection($collezione)
        let $find_testimone := $xml//tei:person[@role="testimone"]
        let $nome_testimone := fn:normalize-space($find_testimone/tei:persName/tei:forename)
        let $cognome_testimone:=fn:normalize-space(string-join($find_testimone/tei:persName/tei:surname, " "))
        let $testimone :=concat($cognome_testimone," ",$nome_testimone)

        
        order by $testimone (: ordino i testimoni in ordine alfabetico per cognome :)
        return $testimone

    
    

    
    
        
        
    return <div id="text">
    
                <head>
                    <script src="https://code.highcharts.com/highcharts.js"></script>
                    <script src="https://code.highcharts.com/modules/exporting.js"></script>
                    <script src="https://code.highcharts.com/modules/accessibility.js"></script>
                    <script src="https://code.highcharts.com/modules/timeline.js"></script>
                    
                    <script src="https://code.highcharts.com/modules/drilldown.js"></script>
                    <script src="https://code.highcharts.com/highcharts-3d.js"></script>
                    <script src="http://code.jquery.com/jquery-latest.min.js"></script>
                    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.2/dist/chart.umd.js"></script>
                    <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2"></script>
                    
                    <script src="https://code.highcharts.com/highcharts.js"></script>
                    <script src="https://code.highcharts.com/modules/treemap.js"></script>
                    <script src="https://code.highcharts.com/modules/treegraph.js"></script>
                    <script src="https://code.highcharts.com/modules/exporting.js"></script>
                    <script src="https://code.highcharts.com/modules/accessibility.js"></script>
                </head>
                
                <p>L’archivio digitale Voci dall’Inferno è attualmente costituito da <b>{$num_testimonianze}</b> testimonianze appartenenti a <b>{$num_archivio}</b> testimoni. Le testimonianze sono state rese da sopravvissuti con storie e provenienze diverse e attraverso differenti modalità, il che ha contribuito a rendere il corpus molto eterogeneo, offrendo allo stesso tempo una visione molto ampia del Lager e del periodo del Nazifascismo. </p>
                <br/>
                
                
                <p> I <b>{$num_archivio}</b> testimoni dell’archivio digitale, dei quali sono state codificate le testimonianze, sono così ripartiti: <b>{$num_deportati_ebrei+$num_deportati_IMI}</b> testimoni vissero l’esperienza del campo di concentramento mentre, attualmente, <b>{$num_non_deportati_partigiani_ebrei}</b> solo testimone non fu deportato. Di coloro che videro il Lager, <b>{$num_deportati_ebrei}</b> sono deportati ebrei, <b>{$num_deportati_IMI}</b> sono internati militari italiani. L’unico testimone che non visse l’esperienza del campo di concentramento che è attualmente presente nell’archivio è il partigiano ebreo Emanuele Artom.
                </p>
                
                <br/>
                
                <p>È stata quindi individuata e stabilita una prima ipotesi di tassonomia del progetto Voci dall’Inferno, non del tutto esaustiva e ancora in via di definizione, che consentisse di identificare e di distinguere le testimonianze rese dai sopravvissuti. </p>
                
                <br/>
                

                
                <p>Nel <em>treegraph chart</em> riportato di seguito è rappresentata la tassonomia dei testimoni che attualmente costituiscono l'archivio.</p>
                 
   
                
                
                <figure class="highcharts-figure1">
                    <div id="container1">
                        <script>
                            Highcharts.chart('container1', {{
                                chart: {{
                                    spacingBottom: 30,
                                    marginRight: 120,
                                    height: 800
                                }},
                                
                                title: {{
                                    text: "Tassonomia dell'archivio Voci dall'Inferno"
                                }},
                                series: [
                                    {{
                                        type: 'treegraph',
                                        keys: ['parent', 'id', 'level'],
                                        clip: false,
                                        data: [
                                            [undefined, 'Testimoni'],
                                            ['Testimoni', 'Deportati'],
                                            ['Testimoni', 'Non deportati'],
                                            ['Deportati', 'Ebrei'],
                                            ['Deportati', 'Internati militari italiani'],
                                            ['Non deportati', 'Partigiani ebrei'],
                                            
                                            // Leaves:
                                            ['Ebrei', 'Goti Bauer', 5],
                                            ['Ebrei', 'Edith Bruck', 5],
                                            ['Ebrei', 'Romana  Feld', 5],
                                            ['Ebrei', 'Nedo Fiano', 5],
                                            ['Ebrei', 'Ida Marcheria', 5],
                                            ['Ebrei', 'Samuel Modiano', 5],
                                            ['Ebrei', 'Liliana Segre', 5],
                                            ['Ebrei', 'Alessandro Smulevich', 5],
                                            ['Ebrei', 'Piero Terracina', 5],
                                            ['Ebrei', 'Shlomo Venezia', 5],
                                            ['Ebrei', 'Arminio Wachsberger', 5],
                                            ['Ebrei', 'Idek Wolfowicz', 5],
                                            
                                            // Leaves for IMI
                                            ['Internati militari italiani', 'Bruno Cimoli', 5],
                                            ['Internati militari italiani', 'Luigi Giuntini',5],
                                            ['Internati militari italiani', 'Alberto Pacini', 5],
                                            ['Internati militari italiani', 'Nicola Ricci', 5],
                                            ['Internati militari italiani', 'Enrico Vanzini',5],
                                            
                                            // Leaves for Partigiani ebrei
                                            ['Partigiani ebrei', 'Emanuele Artom', 5],
                                            
                                           
                                        ],
                                        marker: {{
                                            symbol: 'circle',
                                            radius: 6,
                                            fillColor: '#ffffff',
                                            lineWidth: 3
                                        }},
                                        dataLabels: {{
                                            align: 'left',
                                            pointFormat: '{{point.id}}',
                                            style: {{
                                                color: '#000000',
                                                textOutline: '3px #ffffff',
                                                whiteSpace: 'nowrap'
                                            }},
                                            x: 24,
                                            crop: false,
                                            overflow: 'none'
                                        }},
                                        levels: [
                                            {{
                                                 level: 1,
                                                    levelIsConstant: false,
                                                    color: '#6e7e8e'  // Colore per 'Testimoni'
                                            }},
                                            {{
                                                level: 2,
                                                colorByPoint: true,
                                                colors: ['#1f77b4', '#ff7f0e']  // Colori per 'Deportati' e 'Non deportati'
                                            }},
                                            {{
                                                 level: 3,
                                                colorByPoint: true,
                                                colors: ['#2ca02c', '#d62728']  // Colori per 'Ebrei' e 'IMI'
                                            }},
                                            {{
                                                level: 4,
                                                colorByPoint: true,
                                                colors: ['#9467bd']  // Colore per 'Partigiani ebrei'
                                            }},
                                            {{
                                                level: 6,
                                                dataLabels: {{
                                                    x: 10
                                                }},
                                                marker: {{
                                                    radius: 4
                                                }}
                                            }}
                                        ]
                                    }}
                                ],
                                nodeWidth: 50
                            }});
                        </script>
                        
                        
                    </div>
                    
                </figure>

                <h2 style="text-align:center; margin-bottom:2%;">In che formato si presentano le testimonianze?</h2>
                
                
                <div id="text">
                
                        <p>Le testimonianze che attualmente costituiscono l’archivio digitale si dividono in due macro-classi: da un lato le testimonianze orali e dall’altro le testimonianze scritte. All’interno di ciascuna macro-classe sono individuabili ulteriori tipologie in base a come si presentano le fonti primarie. Le testimonianze appartenenti alla categoria delle testimonianze orali si presentano in formato video o in formato audio, mentre le testimonianze appartenenti alla categoria delle fonti scritte sono costituite da diari, lettere, fogli manoscritti e fascicoli.</p>
                          <br/>
                        <p>
                            Il numero di testimonianze codificate che costituiscono l’archivio digitale è attualmente pari a <b>{$num_testimonianze}</b>. Di questo numero, <b>{$num_testimonianze_orali}</b> sono testimonianze orali, di cui  <b>{$num_testimonianze_video}</b> interviste in formato video e <b>{$num_testimonianze_audio}</b> in formato audio.
                            Le restanti <b>{$num_testimonianze_scritte}</b> sono testimonianze scritte e si compongono di <b>{$num_testimonianze_diari}</b> diari, <b>{$num_testimonianze_lettere}</b> testimonianza in forma di lettera, <b>{$num_testimonianze_fogli_manoscritti}</b> fogli manoscritti e <b>{$num_testimonianze_fascicoli}</b> fascicolo.
                        
                        </p>
                        
                </div>
               
               <figure class="highcharts-figure">
                    <div id="container">
                            <script>
                                    Highcharts.chart('container', {{
                                            chart: {{
                                                type: 'pie',
                                                custom:{{}},
                                                events:{{
                                                    render: function(){{
                                                        var chart = this;
                                                        var total = "Testimonianze totali: <br/><b>{$num_testimonianze}</b>"; 
                                                        
                                                        if (chart.customLabel) {{
                                                            chart.customLabel.destroy();
                                                        }}
                                        
                                                        chart.customLabel = chart.renderer.text(
                                                            total, 
                                                            chart.plotWidth / 2 + chart.plotLeft, // Posizione X
                                                            chart.plotHeight / 2 + chart.plotTop // Posizione Y
                                                        ).css({{
                                                            color: '#000000', 
                                                            fontSize: '20px',
                                                            textAlign: 'center'
                                                        }}).attr({{
                                                            align: 'center',
                                                            zIndex: 5
                                                        }}).add();
                                                    
                                                    }}
                                                    
                                                }}
                                                    
                                            }},
                                            accessibility: {{
                                                point: {{
                                                    valueSuffix: ' '
                                                }}
                                            }},
                                            title: {{
                                                text: 'Tipologie di testimonianza'
                                            }},
                                            
                                            tooltip: {{
                                                pointFormat: '{{series.name}}: <b>{{point.y}}</b>'
                                            }},
                                            legend: {{
                                                enabled: false
                                            }},
                                            plotOptions: {{
                                                series: {{
                                                    allowPointSelect: true,
                                                    cursor: 'pointer',
                                                    borderRadius: 8,
                                                    dataLabels: [{{
                                                        enabled: true,
                                                        distance: 20,
                                                        format: '{{point.name}}',
                                                        style: {{
                                                            fontSize: '14px', // Aumenta la dimensione del font per il nome
                                                        }}
                                                    }}, {{
                                                        enabled: true,
                                                        distance: -15,
                                                        format: '{{point.y}}',
                                                        style: {{
                                                            fontSize: '0.9em'
                                                        }}
                                                    }}],
                                                    showInLegend: true
                                                }}
                                            }},
                                            series: [{{
                                                name: 'Totale',
                                                colorByPoint: true,
                                                innerSize: '75%',
                                                data: [{{
                                                    name: 'Video',
                                                    y: {$num_testimonianze_video},
                                                    color:'#b91d47'
                                                }}, {{
                                                    name: 'Audio',
                                                    y: {$num_testimonianze_audio},
                                                    color: '#00aba9'
                                                }}, {{
                                                    name: 'Diari',
                                                    y: {$num_testimonianze_diari},
                                                    color:'#2b5797' 
                                                }}, {{
                                                    name: 'Lettere',
                                                    y: {$num_testimonianze_lettere},
                                                    color:'#e8c3b9'
                                                }},{{
                                                    name:'Fascicoli',
                                                    y:{$num_testimonianze_fascicoli},
                                                    color: '#1e7145'
                                                }},
                                                {{
                                                    name:'Fogli manoscritti',
                                                    y:{$num_testimonianze_fogli_manoscritti},
                                                    color:'#8c53e0'
                                                    }} ]
                                            }}]
                                            
                                           
                                        }});
                            </script>
                    </div>
                </figure>
                
                
                
                <h2 style="text-align:center; margin-bottom:2%;margin-top:4%;">Da dove provengono le testimonianze?</h2>
                
                <div id="text">
                    La maggior parte delle fonti orali proviene dal fondo di interviste inedite realizzate dalle dottoresse Anna Segre e Gloria Pavoncello negli anni 2005-2006 per la pubblicazione del volume <a href="https://www.annasegre.it/judenrampe/" target="blank" style="text-decoration:none;">"Judenrampe</a>. Le interviste, registrate su micro-cassette, sono state messe a disposizione del progetto e opportunamente convertite in formato mp3.
                    Dei circa 25 sopravvissuti che hanno rilasciato interviste a Segre e Pavoncello, 7 sono stati oggetto di studio del progetto Voci dall’Inferno: Edith Bruck, Ida Marcheria, Idek Wolfowicz, Liliana Segre, Nedo Fiano, Piero Terracina e Shlomo Venezia.
                    <br/>
                    Del fondo Pavoncello-Segre sono state trascritte <b>{$num_ore_trascritte_anna}</b>.
                    <br/>
                    <br/>
                    Le altre due registrazioni audio che costituiscono l’archivio sono quelle di Goti Herskovits Bauer e Arminio Wachsberger. La testimonianza di Herskovitz Bauer è stata realizzata il 7 marzo 2020 da Marina Riccucci e da Laura Ricotti. La testimonianza di Wachsberger appartiene alla Fondazione CDEC ed è stata realizzata a Milano da Liliana Picciotto nell’ambito del progetto "Ricerca sulla deportazione". Le tre testimonianze orali in formato video provengono tutte da YouTube: si tratta delle interviste di Enrico Vanzini, Samuele Modiano e Arminio Wachsberger.
                </div>
                
                
                <figure class="highcharts-figure">
                    <div id="container21">
                            <script>
                                    Highcharts.chart('container21', {{
                                            chart: {{
                                                type: 'pie',
                                                custom:{{}},
                                                events:{{
                                                    render: function(){{
                                                        var chart = this;
                                                        var total = "Testimonianze <br/><em>orali</em>: <br/><b>{$num_testimonianze_orali}</b>"; 
                                                        
                                                        if (chart.customLabel) {{
                                                            chart.customLabel.destroy();
                                                        }}
                                        
                                                        chart.customLabel = chart.renderer.text(
                                                            total, 
                                                            chart.plotWidth / 2 + chart.plotLeft, // Posizione X
                                                            chart.plotHeight / 2 + chart.plotTop // Posizione Y
                                                        ).css({{
                                                            color: '#000000', 
                                                            fontSize: '20px',
                                                            textAlign: 'center'
                                                        }}).attr({{
                                                            align: 'center',
                                                            zIndex: 5
                                                        }}).add();
                                                    
                                                    }}
                                                    
                                                }}
                                                    
                                            }},
                                            accessibility: {{
                                                point: {{
                                                    valueSuffix: ' '
                                                }}
                                            }},
                                            title: {{
                                                text: 'Provenienza delle testimonianze orali'
                                            }},
                                            
                                            tooltip: {{
                                                pointFormat: '{{series.name}}: <b>{{point.y}}</b>'
                                            }},
                                            legend: {{
                                                enabled: false
                                            }},
                                            plotOptions: {{
                                                series: {{
                                                    allowPointSelect: true,
                                                    cursor: 'pointer',
                                                    borderRadius: 8,
                                                    dataLabels: [{{
                                                        enabled: true,
                                                        distance: 20,
                                                        format: '{{point.name}}',
                                                        style: {{
                                                            fontSize: '14px', // Aumenta la dimensione del font per il nome
                                                        }}
                                                    }}, {{
                                                        enabled: true,
                                                        distance: -15,
                                                        format: '{{point.y}}',
                                                        style: {{
                                                            fontSize: '0.9em'
                                                        }}
                                                    }}],
                                                    showInLegend: true
                                                }}
                                            }},
                                            series: [{{
                                                name: 'Testimonianze',
                                                colorByPoint: true,
                                                innerSize: '75%',
                                                data: {$occorrenze_authors_json_output}
                                            }}]
                                            
                                           
                                        }});
                            </script>
                    </div>
                </figure>
                
                
                
                
                <div id="text" style="margin-top:5%;">
                    <p>Per quanto riguarda le fonti scritte, la parte più cospicua proviene da collezioni familiari private. È il caso della testimonianza di Alessandro Smulevich, del quale sono stati digitalizzati 4 fogli manoscritti, di Nicola Ricci e Luigi Giuntini, dei quali sono stati codificati i 2 diari, e di Alberto Pacini, di cui è stato trascritto e digitalizzato il corpus delle 50 lettere di prigionia. Delle rimanenti 3 testimonianze scritte, le testimonianze di Emanuele Artom e Romana Feld appartengono dall’archivio digitale del Centro di Documentazione Ebraica Contemporanea di Milano, mentre la testimonianza di Bruno Cimoli proviene dalla sede centrale dell’ANPI di Massa
                    </p>
                </div>
                
                <figure class="highcharts-figure">
                    <div id="container19">
                            <script>
                                    Highcharts.chart('container19', {{
                                            chart: {{
                                                type: 'pie',
                                                custom:{{}},
                                                events:{{
                                                    render: function(){{
                                                        var chart = this;
                                                        var total = "Testimonianze <br/><em>scritte</em>: <br/><b>{$num_testimonianze_scritte}</b>"; 
                                                        
                                                        if (chart.customLabel) {{
                                                            chart.customLabel.destroy();
                                                        }}
                                        
                                                        chart.customLabel = chart.renderer.text(
                                                            total, 
                                                            chart.plotWidth / 2 + chart.plotLeft, // Posizione X
                                                            chart.plotHeight / 2 + chart.plotTop // Posizione Y
                                                        ).css({{
                                                            color: '#000000', 
                                                            fontSize: '20px',
                                                            textAlign: 'center'
                                                        }}).attr({{
                                                            align: 'center',
                                                            zIndex: 5
                                                        }}).add();
                                                    
                                                    }}
                                                    
                                                }}
                                                    
                                            }},
                                            accessibility: {{
                                                point: {{
                                                    valueSuffix: ' '
                                                }}
                                            }},
                                            title: {{
                                                text: 'Provenienza delle testimonianze scritte'
                                            }},
                                            
                                            tooltip: {{
                                                pointFormat: '{{series.name}}: <b>{{point.y}}</b>'
                                            }},
                                            legend: {{
                                                enabled: false
                                            }},
                                            plotOptions: {{
                                                series: {{
                                                    allowPointSelect: true,
                                                    cursor: 'pointer',
                                                    borderRadius: 8,
                                                    dataLabels: [{{
                                                        enabled: true,
                                                        distance: 20,
                                                        format: '{{point.name}}',
                                                        style: {{
                                                            fontSize: '14px', // Aumenta la dimensione del font per il nome
                                                        }}
                                                    }}, {{
                                                        enabled: true,
                                                        distance: -15,
                                                        format: '{{point.y}}',
                                                        style: {{
                                                            fontSize: '0.9em'
                                                        }}
                                                    }}],
                                                    showInLegend: true
                                                }}
                                            }},
                                            series: [{{
                                                name: 'Testimonianze',
                                                colorByPoint: true,
                                                innerSize: '75%',
                                                data: {$occorrenze_repo_json_output}
                                            }}]
                                            
                                           
                                        }});
                            </script>
                    </div>
                </figure>
                
                
                
                <div id="text" style="margin-top:10%;">
                    <h2 style="text-align:center; margin-bottom:2%;">Quante ore e quante pagine sono state trascritte e codificate?</h2>
                    <p style="text-align:center;">Sono state trascritte e codificate <b>{$num_ore_trascritte}</b> di registrazioni orali e <b>{$num_pagine_trascritte}</b> pagine.</p>
                </div>
                
            </div>
    
};




(: funzione di utilità per aggiungere uno spazio ad ogni figlio degli elementi u, in modo che poi sia piu semplice tokenizzare per spazio :)
declare function local:aggiungi_spazio_tra_enunciati($enunciato) {
    for $figlio in $enunciato/node()
    return ( $figlio, " ")
};


(: funzione di utilità per contare il numero di occorrenze di una specifica parola in una sequenza di parole :)
declare function local:conteggio_parole($sequenza_parole, $termine) {
    (: ottengo la sequenza di tutte le occorrenze trovate :)
    let $trovate := (
        for $parola in $sequenza_parole
        where $parola = $termine
        return $parola
    )
    (: restituisco il conteggio (numero elementi della sequenza = numero occorrenze trovate) :)
    return count($trovate)
};





(: 
  
declare function local:passthru($node as node()*) as item()* {
    element {name($node)} {($node/@*, local:pulizia($node/node()))}
};    
    
    

    
declare function local:pulizia($node as node()) as item()* {
    typeswitch($node)
        (:  :case text() return $node
        case comment() return $node:)
        case element(vocal) return ()
        case element(incident) return ()
        case element(kinesic) return ()
       
        default return $node
};
    
:)
















(:  declare function app:cerca_parola_testimonianza(){
    
    
    
};
:)



declare function functx:capitalize-first
  ( $arg as xs:string? )  as xs:string? {

   concat(upper-case(substring($arg,1,1)),
             substring($arg,2))
 } ;







    

(: --------- pagina cerca_testimone.html -------- :)
declare function app:cerca_testimone($query as xs:string, $model as map(*)) {
    (: Recupera i parametri direttamente dalla richiesta HTTP :)
    let $nome := request:get-parameter("nome", " ")
    let $cognome := request:get-parameter("cognome", " ")
    let $anno_nascita := request:get-parameter("anno_nascita", " ")
    let $luogo_nascita := request:get-parameter("luogo_nascita", " ")
    let $anno_morte := request:get-parameter("anno_morte", " ")
    let $luogo_morte := request:get-parameter("luogo_morte", " ")
    
    
    let $xmlCollection:=collection("/db/apps/voci_inferno/xml")
    
    (: Esegui la query per trovare i testimoni :)
    let $testimoni :=
        for $xml in $xmlCollection/*
            let $find_testimone := $xml//tei:person[@role="testimone"]
            let $name_testimone := $find_testimone/tei:persName/tei:forename
            let $surname_testimone := $find_testimone/tei:persName/tei:surname[1]
            
            let $birth_date := $find_testimone/tei:birth/tei:date
            let $birth_place_settlement := $find_testimone/tei:birth/tei:placeName/tei:settlement[@type="municipality" or @type="island" or @type="town" or @type="city" or @type="città"]
            let $birth_place_country := $find_testimone/tei:birth/tei:placeName/tei:country
            let $birth_place := concat($birth_place_settlement, ", ", $birth_place_country)
            let $death_date := $find_testimone/tei:death/tei:date
            let $death_place := $find_testimone/tei:death/tei:placeName/tei:settlement[@type="municipality" or @type="island" or @type="town" or @type="city" or @type="città"]
           

            (: Crea la stringa del testimone :)
            let $testimone := concat($name_testimone, " ", $surname_testimone, " (", $birth_date, " - ", $birth_place, ")") 
            
            (: Tokenizza le date per estrarre l'anno :)
            let $birth := tokenize($birth_date, " ")
            let $morte := tokenize($death_date, " ")
            
            (: Filtro i risultati sulla base dei parametri forniti :)
            where 
                ($name_testimone = functx:capitalize-first($nome) or 
                 $surname_testimone = functx:capitalize-first($cognome)  or 
                 $birth[3] = $anno_nascita or 
                 $birth_place = functx:capitalize-first($luogo_nascita)  or 
                 $morte[3] = $anno_morte or 
                 $death_place = functx:capitalize-first($luogo_morte) 
                 )
            
            (: Ordino i risultati in ordine alfabetico per cognome :)
            order by $testimone
            
            return $testimone

    
    return
        <div id="risultato_ricerca">
            <h2>Risultati</h2>
            {
               
                    for $testimone in distinct-values($testimoni)
                        let $testimone_split := tokenize($testimone, "\s")
                        let $linkAlTestimone := concat($testimone_split[2], " ", $testimone_split[1])
                        return
                            
                                
                            <p><a class="result_testimone" onclick='mostra_testimonianze("{$linkAlTestimone}")'>{($testimone)}</a></p>
                            
            }
        </div>
};








(: --- PROGETTO_VOCI.HTML --- :)

declare function app:testo_progetto_voci($node as node(), $model as map (*)){
    <div id="text">
        <h2 style="margin-bottom:10px;">Il progetto Voci dall'Inferno</h2>
        <div>
            <p>
            Nei Lager nazisti, pare oltre 60.000, hanno perso la vita quasi 20 milioni di persone: giovani, vecchi e bambini, uomini, donne, ebrei, dissidenti, zingari e omosessuali, internati militari1. Tutto questo è
            accaduto in un arco di tempo breve: dall’aprile 1943 fino al gennaio 1945. Solo il 10 per cento di coloro che subirono la deportazione nei Lager è sopravvissuto ed è tornato a casa. Di questo 10 per cento circa il
            9 per cento è rappresentato da coloro che entrarono in Lager nel 1944. Pochissimi sono i sopravvissuti tra coloro che entrarono in Lager prima di quell’anno: i Lager che noi conosciamo sono i Lager del ’44, degli
            altri sappiamo pochissimo, perché quasi nessuno degli Häftlinge è tornato per raccontarlo. Negli ultimi 5 anni è morta la metà dei superstiti. A raccontare la propria esperienza, a dire il Lager a un pubblico che
            si suppone universale e quindi all’esterno della sfera del proprio privato non sono stati tutti coloro che al Lager sono sopravvissuti, ma una parte, sicuramente non la maggior parte. Di questo gruppo di persone
            solo la minoranza ha iniziato a farlo subito. Per altri ci sono voluti decenni di impenetrabile, ostinato e doloroso silenzio. Molti sopravvissuti hanno taciuto e quindi la loro storia non la conosceremo mai.
            Perché il Lager è ineffabile: «Sento talora l’insufficienza dello strumento. Ineffabilità si chiama, ed è una bellissima parola». Poi, una volta trovata la forza, interviene un altro problema, che è
            quello di trovare le parole: “Di Auschwitz non si saprà mai tutto, perché alcuni accadimenti sembrano destinati a rimanere senza parole”. Per dire il Lager, dunque, occorre superare una barriera dopo l’altra:
            quella dell’ineffabilità – riferire significa ricordare e spesso il ricordo di tanta nefandezza è insostenibile – e quella della povertà del vocabolario, un vocabolario che non ha le parole per dirlo, il Lager, un
            vocabolario senza termini. Dire che il Lager è stato l’inferno ha permesso ai sopravvissuti di stabilire un contatto immediato con i loro ascoltatori, con il loro pubblico, con chi non sapeva e non
            aveva mai voluto sapere. Nelle loro parole ricorre sempre questa metafora condivisa che trova enunciato nella dichiarazione semplice e lineare che il Lager è l’inferno. Sembrerebbe che non ci fosse altro
            da dire. 
            </p>
            <br/>
            <p>
            Dal 2016 Marina Riccucci, docente di Letteratura italiana presso l’Università di Pisa, dirige e coordina, con il supporto del professor Angelo Mario Del Grosso dell’Istituto di Linguistica Computazionale "A.Zampolli" del CNR di Pisa, il progetto di ricerca <em>Voci dall’Inferno</em>.
            <br/>
            Il progetto nasce nell’anno accademico 2015-2016 in occasione del lavoro di tesi della dottoressa Sara Calderini, la quale ha provato a rispondere alla domanda di base ‘se’ e, se sì, ‘quanto e in che misura’, Dante abbia fornito le parole per dire il Lager anche alle testimonianze definite come non letterarie, ovvero la tipologia testuale attraverso cui chi ha vissuto il campo di sterminio ne ha riferito in forme che si collocano nello spazio compreso tra il resoconto orale (l’intervista) e quello scritto (il diario, il racconto autobiografico/memoriale, la lettera). L’indagine parte dal fatto che moltissimi testimoni sopravvissuti ai Lager, indipendentemente dal loro livello di formazione scolastica e culturale, trovano nel lessico dantesco della Divina Commedia, e in particolar modo dell’Inferno, un vocabolario da cui attingere per riuscire a raccontare ciò che non sarebbe stato possibile dire in altro modo.
            </p>
            <br/>
            <p>
            Il progetto si pone quindi due obiettivi, integrati e correlati:
            
            <li>la digitalizzazione e la codifica del primo corpus digitale di testimonianze <em>non letterarie</em> di sopravvissuti ai Lager</li>
            <li>l'individuazione, la quantificazione e la valutazione della presenza di lessico e immagini dantesche all'interno di quelle testimonianze</li>
            
            <br/>
            La realizzazione del corpus digitale consente in primo luogo di raccogliere, conservare e tutelare anche la tipologia delle testimonianze non letterarie, patrimonio storico altrettanto importante che a differenza delle testimonianze letterarie, non è salvaguardato dalla pubblicazione e dalle ristampe, e in secondo luogo di avvalersi di strumenti e metodi informatici per poter svolgere attività di studio, analisi e ricerca su di esse.
            </p>
            
            <p>  Il progetto procede grazie al lavoro di numerosi laureandi, principalmente dei Corsi di Laurea in Informatica Umanistica e in Italianistica, e al supporto del Dipartimento di Filologia, Letteratura e Linguistica dell'Università di Pisa, del <a href="https://www.cdec.it/" target="blank" style="text-decoration:none;">Centro di Documentazione Ebraica Contemporanea di Milano (CDEC)</a>, del <a href="https://www.cise.unipi.it/" target="blank" style="text-decoration:none;">Centro Interdipartimentale di Studi Ebraici (CISE)</a>, del laboratorio <a href="https://cophilab.ilc.cnr.it/" target="blank" style="text-decoration:none;" >CoPhiLab</a> dell'<a href="https://www.ilc.cnr.it/" target="blank" style="text-decoration:none;">Istituto di Linguistica Computazionale </a> del CNR di Pisa e del centro di conoscenza <a href="https://diptext-kc.clarin-it.it/" target="blank" style="text-decoration:none;">CLARIN-IT DiPText-KC</a>.
                </p>
        </div>
    </div>
};




(: ---- funzione per creare elenco studenti ---- :)
declare function app:studenti($node as node(), $model as map(*)){
    let $xmlCollection:=collection("/db/apps/voci_inferno/xml")
    let $studenti := 
        for $xml in $xmlCollection/*
        let $studente := $xml//tei:editionStmt//tei:respStmt[@xml:id="encoder"]
        let $nome_studente :=$studente/tei:persName/tei:forename
        let $cognome_studente := $studente/tei:persName/tei:surname
        let $studente_nome_cognome:=concat($cognome_studente," ",$nome_studente)
        
        
        order by $studente_nome_cognome (: ordino gli studenti in ordine alfabetico :)
        return $studente_nome_cognome
    
        return
            
            <div>
                <div>
                    <p style="margin-bottom:10px;">Studenti del CDS in Informatica Umanistica dell'Università di Pisa che hanno realizzato la codifica XML:</p>
                     
                    {for $studente in distinct-values($studenti)
                        return 
                            <ul>
                                <li>{$studente}</li>
                            </ul>
                       }
                </div>
                
                <div style="margin-top:30px;">
                    <p style="margin-bottom:10px;">Altri studenti che hanno collaborato al progetto svolgendo altre attività:</p>
                    <ul>
                        <li>Ferretti Filippo</li>
                        <li>Palermo Jenny</li>
                        <li>Siragusa Federico</li>
                        <li>Vissani Marco</li>
                    </ul>
                </div>
            </div>
        
        
      
    
    
};

 
declare function app:text_footer($node as node(), $model as map(*)){
    <div class="text_footer"><span>Progetto realizzato da Elvira Mercatanti - Laurea Magistrale in Informatica Umanistica - Università di Pisa </span> <span> - License: <a href="https://creativecommons.org/licenses/by-nc-sa/4.0/" style="color:white">https://creativecommons.org/licenses/by-nc-sa/4.0/</a> </span></div>
};

(: logo exist nel footer :)
declare function app:loghi_footer($node as node(), $model as map (*)){
    
    <div class="loghi">
        <div class="logo_unipi">
            <a href="https://infouma.fileli.unipi.it/" target="blank">
                <img src="resources/images/logo_unipi_orizzontale.png" id="unipi_icon"/>
            </a>
        </div>
        
        <div class="logo_cdec">
            <a href="https://www.cdec.it/" target="blank">
                <img src="resources/images/cdec.png" id="cdec_icon"/>
            </a>
        </div>
        
        <div class="logo_aiucd">
            <a href="http://www.aiucd.it/" target="blank">
                <img src="resources/images/logo_aiucd.png" id="aiucd_icon"/>
            </a>
        </div>
        
        <div class="logo_clarin">
            <a href="http://www.aiucd.it/" target="blank">
                <img src="resources/images/CLARIN-IT.png" id="clarin_icon"/>
            </a>
        </div>
        
        <div class="logo_h2iosc">
            <a href="https://www.h2iosc.cnr.it/" target="blank">
                <img src="resources/images/h2iosc.png" id="h2iosc_icon"/>
            </a>
        </div>
        
        <div class="logo_diptext">
            <a href="https://diptext-kc.clarin-it.it/" target="blank">
                <img src="resources/images/diptext-kc02.png" id="diptext_icon"/>
            </a>
        </div>
    </div>
    
    
    
}; 

declare function app:powered_by($node as node(), $model as map (*)){
    <div class="poweredby">
        <div class="logo_exist">
            <a href="https://exist-db.org/exist/apps/homepage/index.html" target="blank">
                <img src="resources/images/powered-by.png" id="exist_icon"/>
            </a>
        </div>
    </div>
};
























