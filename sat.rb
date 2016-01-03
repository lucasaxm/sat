#!/usr/bin/ruby

# The MIT License (MIT)

# Copyright (c) 2016 Lucas Affonso Xavier de Morais

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require "benchmark" # necessario para cronometrar tempo de execucao

def deep_copy(o)
  # funcao que retorna copia de objeto e tudo que ha dentro dele
  Marshal.load(Marshal.dump(o))
end

def init_vars()
  # preenche hash @vars com as variaveis encontradas nas clausulas e as
  # inicializa com -1
  @clauses.map{|x| x.map{|y| y.delete("~")}}.flatten.uniq.each do |var|
    @vars[var]=-1 # inicializa com -1 (nem true nem false)
  end
end

def translate_clause_to_values(clause)
  # troca as variaveis de uma clausula pelos seus respectivos valores na hash de
  # variaveis
  clause.map! do |var|
    if @vars[var.delete("~")]==-1 # var nao definida ainda
      -1
    else
      if (var[0]=="~")
        (@vars[var.delete("~")]+1)%2 # se tem ~, nega o valor
      else
        @vars[var]
      end
    end
  end
end

def test_clauses()
  # testa se a expressao definida no array de clausulas @clauses eh
  # satisfativel, insatisfativel, ou se nao se sabe ainda.
  result = "Undefined"
  
  aux_clauses = deep_copy(@clauses)
  
  aux_clauses.each do |clause|
    translate_clause_to_values(clause)
    if clause.any?{|var| var==1}
      # se existe algum true(1) na clausula, ta no caminho pra ser Sat
      result="Sat"
    elsif clause.all?{|var| var==0}
      # se todo mundo é false(0), para o processameno pois ja eh Unsat
      result="Unsat"
      break
    else
      # nos outros casos, ainda n sabemos se eh Sat ou Unsat
      result = "Undefined"
      break
    end
  end
  
  result 
end

def set_alone_vars()
  # da valores as variaveis de clausulas unicas, fazendo com que a clausula seja
  # verdadeira
  @clauses.each do |clause|
    if clause.size==1
        if (clause.first[0]=="~")
          @vars[clause.first.delete("~")]=0
        else
          @vars[clause.first.delete("~")]=1
        end
        @instanciacoes+=1
    end
  end
end

def simplify_clauses()
  # remove as clausulas que ja sao verdadeiras e as variaveis que nao fazem
  # diferenca nas demais clausulas tambem atualiza a hash de variaveis para
  # conter apenas as variaveis restantes na expressao
  
  exit_loop=false
  loop do
    if @clauses.size>0
      aux_clauses = deep_copy(@clauses)
    else
      return "Sat"
    end
    aux_clauses.each_with_index do |clause, i|
      translate_clause_to_values(clause)
      if clause.any?{|var| var==1}
        @clauses.delete(@clauses[i])
        break
      else
        clause.each_with_index do |var, j|
          if var==0
            @clauses[i].delete(@clauses[i][j])
          end
        end
      end
      (i+1)==aux_clauses.size ? exit_loop=true : exit_loop=false
    end
    break if exit_loop
  end
  @vars={}
  init_vars()
end

def get_first_unset_var()
  # retorna primeira var encontrada na hash @vars sem valor booleano definido
  @vars.each do |key,value|
    if value==-1
      return key
    end
  end
  return nil
end

def try_values_for_var(var)
    # atribui 1 a var e testa se formula eh Unsat, se for Unsat testa novamente
    # para o valor 0.
    @vars[var]=1
    @instanciacoes+=1
    ret = test_clauses()
    if ret=="Unsat"
      @vars[var]=0
      @instanciacoes+=1
      ret = test_clauses()
    end
    ret
end

def davisputnam()
  # algoritmo de Davis-Putnam para checagem de satisfibilidade
  
  set_alone_vars()
  result = test_clauses()
  if result!="Undefined"
    return result
  end
  simplify_clauses()
  while result!="Sat" do
    var = get_first_unset_var()
    result = try_values_for_var(var)
    break if result=="Unsat"
    simplify_clauses()
    @vars.empty? ? result = "Sat" : result = "Unsat"
    @clauses.empty? ? result = "Sat" : result = "Unsat"
  end
  return result
end

@instanciacoes=0 # contador para numero de instanciacoes
sat="" # variavel que recebera o resultado final, Sat ou Unsat

time = Benchmark.measure do
  # bloco de codigo principal, que terah o tempo cronometrado.
  expression = ARGV[0].delete('^xX0-9&#~') # limpa expressao
  @clauses = [] # variavel global que armazena as clausulas
  expression.split("&").each do |clause|
    # separa as clausulas e armazena no array @clauses
    @clauses << clause.split("#")
  end
  @vars = {}  # hash que tem como chave uma variavel da expressao e como
              # valor 1(true), 0(false) ou -1(undefined)
  init_vars() # inicializa hash @vars
  sat = davisputnam() # checa satisfibilidade
end

print "Tempo de execucao = #{'%.02f' % time.real} segundo(s).\n"\
"Instanciacoes = #{@instanciacoes}\n"\
"#{sat}\n"\
"yes\n"