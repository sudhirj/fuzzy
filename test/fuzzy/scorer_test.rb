require 'minitest'
require 'minitest/spec'
require 'minitest/autorun'
require 'active_support/all'
require 'fuzzy'

class TestScorer < Minitest::Test
	def test_simple_whole_word_scoring
		sc = Fuzzy::Scorer.new([
			{weight: 4, terms: ['a', 'b']},
			{weight: 2, terms: ['c', 'd']}
		])
		assert_in_delta 2.fdiv(6), sc.rank('a'), 0.001
		assert_in_delta 1.fdiv(6), sc.rank('c'), 0.001
	end

	def test_partial_word_scoring
		sc = Fuzzy::Scorer.new([
			{weight: 4, terms: ['ab', 'efwx', nil]},
			{weight: 2, terms: ['eflm', 'gh', '']},
			{weight: 2, terms: []},
			{terms: []},
			{weight: 23},
			{}
		])
		assert_in_delta 1.fdiv(6), sc.rank('a'), 0.001
		assert_in_delta 2.fdiv(6), sc.rank('ab'), 0.001
		assert_in_delta 1.fdiv(12), sc.rank('g'), 0.001
		assert_in_delta [1.fdiv(6), 1.fdiv(12)].sum.fdiv(2), sc.rank('ef'), 0.001

		assert sc.rank('a') > sc.rank('b')
		assert sc.rank('ab') > sc.rank('ef')
		assert_equal sc.rank('ab'), sc.rank('efwx')
		assert_equal sc.rank('eflm'), sc.rank('gh')
		assert sc.rank('ef') > sc.rank('g')
		assert sc.rank('efwx') > sc.rank('gh')
		assert sc.rank('gh') > sc.rank('e')
	end

	def test_tokenization
		sc = Fuzzy::Scorer.new([
			{weight: 4, terms: ['ab', 'cd']},
			{weight: 2, terms: ['ef', 'gh']}
		])
		assert_equal sc.tokenize, ['a', 'ab', 'c', 'cd', 'e', 'ef', 'g', 'gh'].to_set
		assert_equal sc.tokens, sc.tokenize.map{|t| Fuzzy::Scorer::Token.new(t, sc.rank(t))}
	end

	def test_normalization
		sc = Fuzzy::Scorer.new([
			{weight: 4, terms: ['ab', 'cd']},
			{weight: 2, terms: ['ef', 'gh']}
		])
		assert_in_delta sc.normalized_tokens.max_by(&:weight).weight, 1, 0.1
		assert_in_delta sc.normalized_tokens.min_by(&:weight).weight, 0, 0.1
		assert_equal sc.tokens.map(&:token).to_set, sc.normalized_tokens.map(&:token).to_set
	end

end