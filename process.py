#!/usr/bin/python3
import spacy

en = spacy.load("en_core_web_sm")
#en.max_length=2000000
sents = en(open('ChangeLog2').read())
people = [ee for ee in sents.ents if ee.label_ == 'PERSON']
for p in people:
    print(p)
