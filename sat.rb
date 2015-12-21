#!/usr/bin/env ruby

require "minisat"
require "awesome_print"
require "benchmark"

time = Benchmark.measure {
    @solver = MiniSat::Solver.new
    
    # formula = "(x1#x1#x1) & (~x1#~x1#~x1)"
    # formula = "(x1) & (x1)"
    formula = "(x1#x2#x3)&(x1#x2#~x3)&(x1#~x2#x3)&(x1#~x2#~x3)&(~x1#x2#x3)&(~x1#x2#~x3)&(~x1#~x2#x3)&(~x1#~x2#~x3)"
    # formula = "(x1#x2#x3)&(x2#x3#x4)&(x3#x4#x5)&(x4#x5#x6)&(x5#x6#x7)&(x6#x7#x8)&(x7#x8#x9)&(x8#x9#x10)"
    
    vars = {}
    
    formula.tr("~ ","").split("&").each do |andPart|
        andPart.tr("()","").split("#").each do |var|
            vars[var]=@solver.new_var if vars[var].nil?
        end
    end
    ap vars
    
    formula.tr(" ","").split("&").each do |andPart|
        clause = []
        andPart.tr("()","").split("#").each do |var|
            if var[0]=="~"
                clause << -vars[var[1..-1]]
            else
                clause << vars[var]
            end
        end
        ap clause
        @solver << clause
    end
    
    @solver.solve
    
    # puts @solver.inspect
    
    # pega a formula da linha de comando
    # ARGV.size==1 ? formula = ARGV.first : abort("numero de parametros incorreto.")
    
    
    # puts formula
}

puts "Tempo de execucao = #{'%.02f' % time.real} segundo(s)."\
"Instanciacoes = #{@solver.clause_size}"\
"#{@solver.satisfied? ? 'Sat' : 'Unsat'}"