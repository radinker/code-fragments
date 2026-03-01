#!/usr/bin/python

# Legacy Fragment 0 -- Hack Computer Assembler
# Author: Jose Arboleda
# Date: 2015
# Copyright: MIT License 2026

__author__ = 'nando'

import sys
import distutils.text_file

# Classes and variables

baseAddress = 16
romAddres = -1

# This class provides the symbol table for tha hack assambly language program
class HackTable():
    class Pair():
        def __init__(self, symName, symVal):
            self.symName = symName
            self.symVal = symVal

    def __init__(self):
        self.symList = [self.Pair('R0', 0)]
        for i in range(1, 16, 1):
            self.symList.append(self.Pair('R' + str(i), i))
        self.symList.append(self.Pair('SP', 0))
        self.symList.append(self.Pair('LCL', 1))
        self.symList.append(self.Pair('ARG', 2))
        self.symList.append(self.Pair('THIS', 3))
        self.symList.append(self.Pair('THAT', 4))
        self.symList.append(self.Pair('SCREEN', 16384))
        self.symList.append(self.Pair('KBD', 24576))

    def displayTable(self):
        print 'Hack Program Symbol Table\r\n'
        for s in self.symList:
            print 'Symbol:%s Address=%i' % (s.symName, s.symVal)

    def symbolLookUp(self, x):
        for s in self.symList:
            if (s.symName == x):
                return s.symVal
        return -1


# This class provides the hack assambly language parser
class hackParser():
    def __init__(self):
        self.id = ''
        self.aVal = ''
        self.comp = ''
        self.dest = ''
        self.jump = ''
        self.codedLine = ''

    def parseCommand(self, line, astring, symt):
        self.id = ''
        self.aVal = ''
        self.comp = ''
        self.dest = ''
        self.jump = ''

        if (line[0] != '/') and (line[0] != '('):
            if line[0] == '@':
                self.id = '0'
                if astring.isdigit():
                    self.aVal = astring
                elif symt.symbolLookUp(astring) != -1:
                    self.aVal = str(symt.symbolLookUp(astring))
                else:
                    self.aVal = ''
                    print 'Bad symbol'
            else:
                n = 0
                cCommand = ''
                self.id = '1'
                last = False
                first = False
                while n < (len(line)):
                    if line[n] == '/':
                        break
                    if (line[n] != '=') and (line[n] != ';'):
                        cCommand = cCommand + line[n]
                    elif (line[n] == '='):
                        self.dest = cCommand
                        cCommand = ''
                        first = True
                    elif (line[n] == ';'):
                        self.comp = cCommand
                        cCommand = ''
                        last = True
                    n += 1
                if last:
                    self.jump = cCommand
                elif first:
                    self.comp = cCommand

    def codeCommand(self, line):
        self.codedLine = ''
        if(line[0] != '/') and (line[0] != '('):
            if self.id == '0':
                self.codedLine = '0' + '{:015b}'.format(int(self.aVal))
            elif self.id == '1':
                #self.codedLine = 'NULL'
                self.codedLine = '111'

                #code comp field
                if self.comp == '0':
                    self.codedLine = self.codedLine + '0101010'
                elif self.comp == '1':
                    self.codedLine = self.codedLine + '0111111'
                elif self.comp == '-1':
                    self.codedLine = self.codedLine + '0111010'
                elif self.comp == 'D':
                    self.codedLine = self.codedLine + '0001100'
                elif self.comp == 'A':
                    self.codedLine = self.codedLine + '0110000'
                elif self.comp == '!D':
                    self.codedLine = self.codedLine + '0001101'
                elif self.comp == '!A':
                    self.codedLine = self.codedLine + '0110001'
                elif self.comp == '-D':
                    self.codedLine = self.codedLine + '0001111'
                elif self.comp == '-A':
                    self.codedLine = self.codedLine + '0110011'
                elif self.comp == 'D+1':
                    self.codedLine = self.codedLine + '0011111'
                elif self.comp == 'A+1':
                    self.codedLine = self.codedLine + '0110111'
                elif self.comp == 'D-1':
                    self.codedLine = self.codedLine + '0001110'
                elif self.comp == 'A-1':
                    self.codedLine = self.codedLine + '0110010'
                elif self.comp == 'D+A':
                    self.codedLine = self.codedLine + '0000010'
                elif self.comp == 'D-A':
                    self.codedLine = self.codedLine + '0010011'
                elif self.comp == 'A-D':
                    self.codedLine = self.codedLine + '0000111'
                elif self.comp == 'D&A':
                    self.codedLine = self.codedLine + '0000000'
                elif self.comp == 'D|A':
                    self.codedLine = self.codedLine + '0010101'
                elif self.comp == 'M':
                    self.codedLine = self.codedLine + '1110000'
                elif self.comp == '!M':
                    self.codedLine = self.codedLine + '1110001'
                elif self.comp == '-M':
                    self.codedLine = self.codedLine + '1110011'
                elif self.comp == 'M+1':
                    self.codedLine = self.codedLine + '1110111'
                elif self.comp == 'M-1':
                    self.codedLine = self.codedLine + '1110010'
                elif self.comp == 'D+M':
                    self.codedLine = self.codedLine + '1000010'
                elif self.comp == 'D-M':
                    self.codedLine = self.codedLine + '1010011'
                elif self.comp == 'M-D':
                    self.codedLine = self.codedLine + '1000111'
                elif self.comp == 'D&M':
                    self.codedLine = self.codedLine + '1000000'
                elif self.comp == 'D|M':
                    self.codedLine = self.codedLine + '1010101'
                else:
                    self.codedLine = 'NULL'

                #code dest field
                if self.dest == '':
                    self.codedLine += '000'
                elif self.dest == 'M':
                    self.codedLine += '001'
                elif self.dest == 'D':
                    self.codedLine += '010'
                elif self.dest == 'MD':
                    self.codedLine += '011'
                elif self.dest == 'A':
                    self.codedLine += '100'
                elif self.dest == 'AM':
                    self.codedLine += '101'
                elif self.dest == 'AD':
                    self.codedLine += '110'
                elif self.dest == 'AMD':
                    self.codedLine += '111'
                else:
                    self.codedLine = 'NULL'

                #code jump field
                if self.jump == '':
                    self.codedLine += '000'
                elif self.jump == 'JGT':
                    self.codedLine += '001'
                elif self.jump == 'JEQ':
                    self.codedLine += '010'
                elif self.jump == 'JGE':
                    self.codedLine += '011'
                elif self.jump == 'JLT':
                    self.codedLine += '100'
                elif self.jump == 'JNE':
                    self.codedLine += '101'
                elif self.jump == 'JLE':
                    self.codedLine += '110'
                elif self.jump == 'JMP':
                    self.codedLine += '111'
                else:
                    self.codedLine = 'NULL'


# Assamble the program
if len(sys.argv) > 1:
    # open input file
    inputFile = file(sys.argv[1])
    #outputFile = file('out.hack')
    # create symbol table
    symTable = HackTable()
    #create parser
    comParser = hackParser()

    inputText = distutils.text_file.TextFile('source', inputFile, lstrip_ws='true')
    lines = inputText.readlines()

    # first pass
    for line in lines:
        if (line[0] != '/') and (line[0] != '('):
            romAddres = romAddres + 1

        if line[0] == '(':
            n = 1
            strLabel = ''
            while n <= (len(line) - 1):
                if line[n] != ')':
                    strLabel = strLabel + line[n]
                n = n + 1

            if symTable.symbolLookUp(strLabel) == -1:
                symTable.symList.append(symTable.Pair(strLabel, romAddres + 1))

    # second pass
    for line in lines:
        #remove white spaces
        line = line.replace(' ', '')

        strLabel = ''
        newLine = ''
        if line[0] == '@':
            n = 1
            # strLabel = ''
            while n <= (len(line) - 1):
                strLabel = strLabel + line[n]
                n = n + 1

            if (symTable.symbolLookUp(strLabel) == -1) and (not strLabel.isdigit()):
                symTable.symList.append(symTable.Pair(strLabel, baseAddress))
                baseAddress = baseAddress + 1

        comParser.parseCommand(line, strLabel, symTable)
        comParser.codeCommand(line)
        if (line[0] != '/') and (line[0] != '('):
            print comParser.codedLine

        #display line by line
        # if comParser.id == '0':
        #     print '@' + comParser.aVal + '\r\n'
        # elif comParser.id == '1':
        #     if comParser.dest == '':
        #         print comParser.comp + ';' + comParser.jump
        #     elif comParser.jump == '':
        #         print comParser.dest + '=' + comParser.comp
        #     else:
        #         print comParser.dest + '=' + comParser.comp + ';' + comParser.jump


    #symTable.displayTable()

else:
    print('No input file!')
