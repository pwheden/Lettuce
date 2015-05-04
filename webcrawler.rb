# coding: utf-8

#Testing building a web crawler
#If Mechanize proves difficult installing, it's because there's a bug with Command Line Tools for Xcode 6.3
#Download for 6.2 @ https://developer.apple.com/downloads/index.action#

require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'json'

require_relative 'NameSkills'
require_relative 'AlsoViewed'

#Initialize Mechanize
agent = Mechanize.new
agent.user_agent_alias = "Mac Safari"
agent.follow_meta_refresh = true

#What company are you interested in?
puts "What company are you interested in? "
Insert_Company = gets.chomp

#Where do most of the company employees reside?
puts "Where do most of the company employees reside? "
country = gets.chomp

if country.casecmp("Sweden") == 0 #0 is true
	prefix = "se"
elsif country.casecmp("Norway") == 0
	prefix = "no"
elsif country.casecmp("Spain") == 0
	prefix = "es"
else	
	prefix = "com"
end

#Do a Google search of "experience 'Insert_Company' LinkedIn"
page = agent.get("https://www.google.com/ncr")
page = agent.get("https://www.google.#{prefix}")
search_form = page.form('f')
search_form.q = "experience #{Insert_Company} LinkedIn"
page = agent.submit(search_form, search_form.buttons[0])

#Find all links with "Something | LinkedIn" and put them the names in L, and the links in M
i = 2
L = []
M = []
while i<5 do
	page.links.each do |link|
  		if link.text.include? "| LinkedIn"
  			L.push(link.text.slice(0..(link.text.index('|')-1)))
  			#M.push(URI.extract("#{link.uri()}"))
  			M.push("https://www.google.#{prefix}#{link.uri}")
  		end
	end
#Scroll through the first 10 Google search pages and continue filling the list L and M.
	if agent.page.links_with(:text => "#{i}")[0] != nil
		page = agent.page.links_with(:text => "#{i}")[0].click
	end
	i += 1
end
M = M.uniq

#Click each link in M, see if the person has experience from 'Insert_Company' and in that case, save their skills in a list N with their name.
N = Hash.new
#N[Insert_Company] = {}
for i in 0..(M.length-1)
	puts "#{(((i+1)*100)/M.length.to_f).round(1)}% completed. Please hold on while we crunch the numbers."
 	hash_name, hash_skills = NameSkills(Insert_Company, "#{M[i]}")
 		if (hash_name.empty? == false && hash_skills.empty? == false)
 			N[hash_name] = {'Skills'=>hash_skills, 'LinkedIn URL' => M[i]}
 			#N[Insert_Company][hash_name] = {'Skills'=>hash_skills, 'LinkedIn URL'=>M[i]}
 		end
end

P = Hash.new
for i in 0..(M.length-1)
	A = AlsoViewed(Insert_Company, "#{M[i]}")
	P = P.merge(A)
end

n = N.merge(P)
p = Hash.new
p[Insert_Company] = n

p[Insert_Company].each do |key, value|
	File.open("out.txt", 'a') do |f| 
		f.write("#{key}:#{value}")
		f.write "\n"
		f.write "\n"
	end
	puts "#{key}:#{value}"
	puts
end
