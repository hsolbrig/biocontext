MODS := obo idot idot_nr semweb monarch semweb_vocab ro_vocab uber
MODS_WITHOUT_UBER := obo idot idot_nr semweb monarch semweb_vocab ro_vocab

all: $(patsubst %,registry/%_context.jsonld,$(MODS))

install:
	pip install -r requirements.txt

test: all

## OBO
## For now we just clone this from ROBOT; TODO - better way of syncing with OBO
##
registry/obo_context.jsonld:
	wget --no-check-certificate http://obofoundry.org/registry/obo_context.jsonld -O $@

registry/minerva_context.jsonld:
	wget --no-check-certificate https://raw.githubusercontent.com/geneontology/minerva/master/minerva-core/src/main/resources/amigo_context_manual.jsonld -O $@

## IDENTIFIERS.ORG
##
## Everything from MIRIAM registry
registry/idot_context.jsonld: registry/miriam.ttl
	 ./bin/miriam2jsonld.pl $< > $@

## NON-REDUNDANT IDOT
##
## OBO Library takes priority, we subtract OBO from IDOT
registry/idot_nr_context.jsonld: registry/idot_context.jsonld registry/obo_context.jsonld
	python3 ./bin/subtract-context.py $^ > $@.tmp && mv $@.tmp $@

## Generic: derived from manually curated source
registry/%_context.jsonld: registry/%_context.yaml
	./bin/yaml2json.py $< > $@.tmp && mv $@.tmp $@

## COMBINED
##
## The kitchen sink

UBER = obo idot_nr semweb
registry/uber_context.jsonld: $(patsubst %,registry/%_context.jsonld,$(MODS_WITHOUT_UBER))
	python3 ./bin/concat-context.py $^ > $@.tmp && mv $@.tmp $@

## DEPENDENCIES

registry/miriam.ttl:
	wget http://www.ebi.ac.uk/miriam/main/export/registry.ttl -O $@

## GO

registry/go-db-xrefs.json: ../go-site/metadata/db-xrefs.yaml
	./bin/yaml2json.pl $< > $@
