#!/usr/bin/ruby

require "benchmark"
require "awesome_print"

def deep_copy(o)
  # funcao que retorna copia de objeto e tudo que ha dentro dele
  Marshal.load(Marshal.dump(o))
end

def init_vars()
  # preenche hash @vars com as variaveis encontradas nas clausulas e as inicializa com -1
  @clauses.map{|x| x.map{|y| y.delete("~")}}.flatten.uniq.each do |var|
    @vars[var]=-1 # inicializa com -1, q eh um valor invalido (nem true nem false)
  end
end

def translate_clause_to_values(clause)
  # troca as variaveis de uma clausula pelos seus respectivos valores na hash de variaveis
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
  # testa se a expressao definida no array de clausulas @clauses eh satisfativel, insatisfativel, ou se nao se sabe ainda.
  result = "Undefined"
  
  aux_clauses = deep_copy(@clauses)
  
  aux_clauses.each do |clause|
    translate_clause_to_values(clause)
    if clause.any?{|var| var==1} # se existe algum true(1) na clausula, ta no caminho pra ser Sat
      result="Sat"
    elsif clause.all?{|var| var==0} # se todo mundo é false(0), para o processameno pois ja eh Unsat
      result="Unsat"
      break
    else # nos outros casos, ainda n sabemos se eh Sat ou Unsat
      result = "Undefined"
      break
    end
  end
  
  result 
end

def set_alone_vars()
  # da valores as variaveis de clausulas unicas, fazendo com que a clausula seja verdadeira
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
  # remove as clausulas que ja sao verdadeiras e as variaveis que nao fazem diferenca nas demais clausulas
  # tambem atualiza a hash de variaveis para conter apenas as variaveis restantes na expressao
  
  # puts "\nSimplificando clausulas"
  exit_loop=false
  loop do
    if @clauses.size>0
      aux_clauses = deep_copy(@clauses)
    else
      return "Sat"
    end
    aux_clauses.each_with_index do |clause, i|
      translate_clause_to_values(clause)
      # puts "\nClausula:"
      # ap clause
      if clause.any?{|var| var==1}
        @clauses.delete(@clauses[i])
        # puts "Removida"
        # puts "Novo estado:"
        # ap @clauses
        break
      else
        clause.each_with_index do |var, j|
          if var==0
            @clauses[i].delete(@clauses[i][j])
            # puts "Var removida"
            # puts "Novo estado:"
            # ap @clauses
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

def get_first_key_of_unset_var()
  # retorna primeira var encontrada na hash @vars sem valor booleano definido
  @vars.each do |key,value|
    if value==-1
      return key
    end
  end
  return nil
end

def davisputnam()
  # algoritmo de Davis-Putnam para checagem de satisfibilidade
  
  set_alone_vars()
  # puts "\nVars de clausulas unicas setadas:"
  # ap @vars
  ret = test_clauses()
  if ret!="Undefined"
    return ret
  end
  simplify_clauses()
  # puts "\nClausulas simplificadas"
  # ap @clauses
  # puts "\nVariaveis restantes"
  # ap @vars
  # passo 6
  while ret!="Sat" do
    key = get_first_key_of_unset_var()
    @vars[key]=1
    @instanciacoes+=1
    ret = test_clauses()
    if ret=="Unsat"
      @vars[key]=0
      @instanciacoes+=1
      ret = test_clauses()
      if ret=="Unsat"
        return ret
      end
    end
    simplify_clauses()
    @vars.empty? ? ret = "Sat" : ret = "Unsat"
    @clauses.empty? ? ret = "Sat" : ret = "Unsat"
  end
  return ret
end

@instanciacoes=0
sat=""

time = Benchmark.measure do
  expression = ARGV[0].delete('^xX0-9&#~') # remove '?- sat()".' from input
  # puts "\nEntrada"
  # ap ARGV[0]
  # puts "\nExpressao"
  # ap expression
  @clauses = [] # variavel global que armazena as clausulas
  expression.split("&").each do |clause|
    @clauses << clause.split("#")
  end
  @vars = {} # hash que tem como chave uma variavel da expressao e como valor 
  init_vars()
  # puts "\nClausulas originais"
  # ap @clauses
  # puts "\nVariaveis"
  # ap @vars
  sat = davisputnam()
end

# f.close

print "Tempo de execucao = #{'%.02f' % time.real} segundo(s).\n"\
"Instanciacoes = #{@instanciacoes}\n"\
"#{sat}\n"\
"yes\n"