class TgnUk < TGN

  def sparql(q)
    search = untaint(q)
    # The full text index matches on fields besides the term, so we filter to ensure the match is in the term.
    sparql = "SELECT ?s ?name ?par {
              ?s a skos:Concept; luc:term \"#{search}\";
                 skos:inScheme <http://concept_scheme.getty.edu/tgn/> ;
                 gvp:prefLabelGVP [skosxl:literalForm ?name] ;
                  gvp:parentString ?par .
              FILTER regex(?name, \"#{search}\", \"i\") .
              FILTER regex(?par, \"United Kingdom\", \"i\") .
            } LIMIT 10"
  end

end
