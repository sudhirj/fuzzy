require "fuzzy/version"

module Fuzzy
  class Scorer
    Token = Struct.new(:token, :weight)

    TermSet = Struct.new(:weight, :terms) do
      def cleaned_terms
        terms.flat_map{|t| t.parameterize.split('-')}.to_set
      end

      def token_weight total_weight
        weight.fdiv(total_weight * terms.size)
      end

      def tokens total_weight
        cleaned_terms.map do |term|
          Token.new term, token_weight(total_weight)
        end
      end
    end

    def initialize corpus
      corpus = (corpus || []).reject{|c| c[:weight].blank? or c[:terms].blank?}
      @corpus = corpus.map{|c| TermSet.new(c[:weight], c[:terms].reject{|t| t.blank?})}
      @total_weight = @corpus.sum {|c| c.weight}
      @weighted_tokens = @corpus.flat_map{ |c| c.tokens @total_weight }
    end

    def rank query
      scores = @weighted_tokens.map do |wt|
        length_score = wt.token.starts_with?(query) ? query.length.fdiv(wt.token.length) : 0
        length_score * wt.weight
      end
      score_count = scores.count{|s| s > 0}
      return 0 unless score_count > 0
      scores.sum / score_count
    end

    def tokenize
      @corpus.flat_map{|c| c.cleaned_terms.to_a}.flat_map do |str|
        (1..str.length).map { |len| str.slice(0, len) }
      end.to_set
    end

    def tokens
      tokenize.map{|t| Token.new(t, rank(t))}
    end

    def normalized_tokens
      basic_tokens = tokens
      max = basic_tokens.max_by(&:weight).weight
      min = basic_tokens.min_by(&:weight).weight
      # Calculate m and c values for the linear transform y=mx+c
      # m = (y' - y)/(x' - x)
      m = (1 - 0).fdiv(max - min)
      # Substituting the max values in, we get 1 = m(max) + c
      c = 1 - (m * max)
      basic_tokens.map{|t| Token.new(t.token, (t.weight*m + c))}
    end

  end
end