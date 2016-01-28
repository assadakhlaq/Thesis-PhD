require 'rubypost'

require 'matrix'
require 'mathn'

include RubyPost

file = RubyPost::File.new('latticefigures')

@@start_of_file = <<END_OF_STRING
prologues := 2;
filenametemplate "%j-%c.mps";
verbatimtex
%&latex
\\documentclass{minimal}
\\usepackage{amstext}
\\begin{document}
etex
END_OF_STRING

pic = Picture.new('picL')

scaleall = 0.8

M = Matrix[ [3,0.6], [0.6*1.2, 3*1.2] ]*scaleall
(-7..7).each do |x|
	(-7..7).each do |y|
		v = M*Vector[x,y]
pic.add_drawable(Fill.new(Circle.new()).scale(0.07.cm).translate(v[0].cm,v[1].cm).colour(0,0,0))
	end
end

#matrix with columns given by vectors from obtuse superbasis
B = Matrix[ 
           [3.0, -2.4, -0.6], 
           [0.6*1.2, 2.4*1.2, -3.0*1.2] 
]*scaleall

fig1 = Figure.new

#draw a picture of a bigshaded square that we will clip to the Voronoi region
vorPic = Picture.new('vorregion')
vorPic.add_drawable(Fill.new(Square.new).scale(15.cm).colour(0.7,0.7,0.7))

#relevant vector given by the appropriate combinations of the obtuse superbasis
(0..1).each do |x|
  (0..1).each do |y|
    (0..1).each do |z|
      if( ((x+y+z)!=0) && ((x+y+z)!=3) )
        v = (B*Vector[x,y,z])*0.5
        pv = Vector[1/v[0], -1/v[1]]*30
        clipp = Path.new
        clipp.add_pair(Pair.new((pv+v)[0].cm, (pv+v)[1].cm))
        clipp.add_pair(Pair.new((pv*(-1)+v)[0].cm, (pv*(-1)+v)[1].cm))
        clipp.add_pair(Pair.new((pv*(-1)-v)[0].cm, (pv*(-1)-v)[1].cm))
        clipp.add_pair(Pair.new((pv-v)[0].cm, (pv-v)[1].cm))
        clipp.add_pair('cycle')
        fig1.add_drawable(Clip.new(clipp, vorPic))
      end
    end
  end
end

clippath = "((-4cm,-3cm)--(4.5cm,-3cm)--(4cm,3cm)--(-4cm,3cm)--cycle)"
fig1.add_drawable(Clip.new(clippath, pic))
fig1.add_drawable(Clip.new(clippath, vorPic))
fig1.add_drawable(Draw.new(vorPic))
fig1.add_drawable(Draw.new(pic))
#(0..1).each do |x|
#  (0..1).each do |y|
#    (0..1).each do |z|
#      if( ((x+y+z)!=0) && ((x+y+z)!=3) )
#        v = B*Vector[x,y,z]
#        fig1.add_drawable(Draw.new(Circle.new()).scale(0.15.cm).translate(v[0].cm,v[1].cm))
#      end
#    end
#  end
#end

#this is a picture that shows a packing and the inradius
picsphp = Picture.new('picsphp')
v = M*Vector[1,0]/2.0
dminv = M*Vector[0,1]
inradp = Path.new
alpha = 0.0
#pv = Vector[1/v[0], -1/v[1]]*0.025
#lengthtickpair = Path.new
#lengthtickpair.add_pair(Pair.new(pv[0].cm,pv[1].cm))
#lengthtickpair.add_pair(Pair.new((-pv[0]).cm,(-pv[1]).cm))
#picsphp.add_drawable(Draw.new(lengthtickpair).translate((v[0]*alpha).cm, (v[1]*alpha).cm))
#picsphp.add_drawable(Draw.new(lengthtickpair).translate((v[0]*(1-alpha)).cm, (v[1]*(1-alpha)).cm))
dmin = Path.new
dmin.add_pair(Pair.new((dminv[0]*alpha).cm, (dminv[1]*alpha).cm))
dmin.add_pair(Pair.new((dminv[0]*(1-alpha)).cm, (dminv[1]*(1-alpha)).cm))
#picsphp.add_drawable(Arrow.new(dmin))
#picsphp.add_drawable(Label.new(latex('$\displaystyle d_{\text{min}}$'), Pair.new(0,0)).rotate(78).translate((dminv[0]/1.4).cm, (dminv[1]/1.4).cm) )
inradp.add_pair(Pair.new((v[0]*alpha).cm, (v[1]*alpha).cm))
inradp.add_pair(Pair.new((v[0]*(1-alpha)).cm, (v[1]*(1-alpha)).cm))
picsphp.add_drawable(Arrow.new(inradp))
picsphp.add_drawable(Label.new(latex('$\displaystyle \rho$'), Pair.new((v[0]/2).cm, (v[1]/2).cm)) )
(-5..5).each do |x|
  (-5..5).each do |y|
    v = M*Vector[x,y]
    picsphp.add_drawable(Draw.new(Circle.new()).scale(((M*Vector[1,0]).r).cm).translate(v[0].cm,v[1].cm))
  end
end
fig1.add_drawable(Clip.new(clippath, picsphp))
fig1.add_drawable(Draw.new(picsphp))

detLattice = M.determinant
reff = Math.sqrt(detLattice/Math::PI)
fig1.add_drawable(Draw.new(Circle.new()).scale((reff*2).cm).add_option(Dashed.new))

file.add_figure(fig1)



file.compile
