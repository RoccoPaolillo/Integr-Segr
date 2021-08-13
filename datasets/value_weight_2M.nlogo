globals [
  percent-similar-eth
  percent-similar-val
]

patches-own [
 uti-eth
 uti-val
  systemic_utility
; id ; for checking utility with new function, delete
]


turtles-own [
  movers?
]


to setup
  clear-all
  ask patches [
    set pcolor white
    if random 100 < density [sprout 1
      [
        ifelse random 100 < fraction_blue
      [ set color blue
        set shape ifelse-value (random 100 < circle_blue) ["circle"]["square"]          ; attributes of agents
      ]

      [set color orange
        set shape ifelse-value (random 100 < circle_orange) ["circle"]["square"]
      ]
      ]
    ]
  ]
  update-globals
  reset-ticks
end


to go
  move-turtles       ; relocation decision of turtles
  update-globals
tick
end

to move-turtles          ; here the relocation decision, I might simplify further

  ask turtles [

  let beta-ie ifelse-value (shape = "square") [dominant_con][(1 - dominant_lib)]   ; beta ethnic by value: for conservatives dominant, for liberals (1 - dominant)
 let beta-iv ifelse-value (shape = "square") [(1 - dominant_con)][dominant_lib]   ; beta value by value: for conservatives (1-dominant); for liberals dominant

 let peak_e ifelse-value (shape = "square") [eth_con][eth_lib]   ; ethnic homophily threshold, varying between value orientation
 let peak_v ifelse-value (shape = "square") [val_con][val_lib]   ; value homophily threshold, varying between value orientation

  let M_e ifelse-value (shape = "square")[M_con_dom][M_lib_sec]
    let M_v ifelse-value (shape = "square") [M_con_sec][M_lib_dom]
  ; let determinism ifelse-value (shape = "square")[determinism_con][determinism_lib]

   let ethnicity-myself color
   let shape-myself shape
   let alternative one-of patches with [not any? turtles-here]   ; one empty cell is selected as alternative
   let trial random-float 1.00                                   ; random number to compare to probability to move to alternative

    let options (patch-set patch-here alternative)   ; the basket choice made of current patch and alternative

    ask options [
  ;    set id [who] of myself

      let xe count (turtles-on neighbors) with [color = ethnicity-myself]     ; similars ethnic in neighborhood
      let xv count (turtles-on neighbors) with [ shape = shape-myself]        ; similars value in  neighborhood

      let n count (turtles-on neighbors)      ; total agents in neighborhood

      set uti-eth  utility_e xe n peak_e  M_e  ; ethnic utility computation (below the report)
      set uti-val  utility_v xv n peak_v  M_v   ; value utility computation (below the report)

      set systemic_utility (determinism * ((beta-ie * uti-eth) + (beta-iv * uti-val)))   ; systemic utility (ethnic + value)
    ]

    let proba (1 / (1 + exp([systemic_utility] of patch-here - [systemic_utility] of alternative))) ; probability to move to alternative(logistic function).
                                                                                                    ; Train (2009) p.39 as transformation logit (expU/Sum(expU)) for 2 options
    ifelse trial <  proba [set movers? TRUE move-to alternative][set movers? FALSE] ; if probability calculated is higher than trial number [0,1], then the agent relocates  to alternative

  ]

end





to update-globals
  let similar-eth sum [ count (turtles-on neighbors) with [color = [color] of myself] ] of turtles
  let similar-val sum [ count (turtles-on neighbors) with [shape = [shape] of myself] ] of turtles
  let total-neighbors sum [ count (turtles-on neighbors)  ] of turtles
  set percent-similar-eth (similar-eth / total-neighbors)
  set percent-similar-val (similar-val / total-neighbors)

end

to-report utility_e [sim tot peak M_e]   ; the three types of utility functions: threshold, single-peaked, linear + constant

 report ( ifelse-value (tot = 0) [0]
    [ifelse-value (sim <= (tot * peak))
   [ precision (sim / (tot * peak))  3
       ][ precision (  (2 - M_e) + ( ((M_e - 1) * sim) / (tot * peak) )   ) 3 ]
  ]
    )

end

to-report utility_v [sim tot peak M_v]   ; the three types of utility functions: threshold, single-peaked, linear + constant

 report ( ifelse-value (tot = 0) [0]
    [ifelse-value (sim <= (tot * peak))
   [ precision (sim / (tot * peak))  3
       ][ precision (  (2 - M_v) + ( ((M_v - 1) * sim) / (tot * peak) )   ) 3 ]
  ]
    )

end

to-report 	et_gl	report	mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1]	end
to-report 	vl_gl	report	mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1]	end
to-report 	den_gl	report	mean [count (turtles-on neighbors)] of turtles / 8	end
to-report 	et_sq	report	mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = "square"]	end
to-report 	et_cl	report	mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = "circle"]	end
to-report 	vl_sq	report	mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = "square"]	end
to-report 	vl_cl	report	mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = "circle"]	end
to-report 	den_sq	report	mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8	end
to-report 	den_cl	report	mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8	end
to-report 	et_bl	report	mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and color = blue]	end
to-report 	et_or	report	mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and color = orange]	end
to-report 	vl_bl	report	mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and color = blue]	end
to-report 	vl_or	report	mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and color = orange]	end
to-report 	den_bl	report	mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8	end
to-report 	den_or	report	mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8	end
to-report 	et_sq_bl	report	mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = "square" and color = blue]	end
to-report 	et_cl_bl	report	mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = "circle" and color = blue]	end
to-report 	et_sq_or	report	mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = "square" and color = orange]	end
to-report 	et_cl_or	report	mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = "circle" and color = orange]	end
to-report 	vl_sq_bl	report	mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = "square" and color = blue]	end
to-report 	vl_cl_bl	report	mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = "circle" and color = blue]	end
to-report 	vl_sq_or	report	mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = "square" and color = orange]	end
to-report 	vl_cl_or	report	mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and  shape = "circle" and color = orange]	end
to-report 	den_sq_bl	report	mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8	end
to-report 	den_sq_or	report	mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8	end
to-report 	den_cl_bl	report	mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8	end
to-report 	den_cl_or	report	mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8	end
to-report 	cls_et_sq_bl	report	mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) >= 1]	end
to-report 	cls_et_cl_bl	report	mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) >= 1]	end
to-report 	cls_et_sq_or	report	mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) >= 1]	end
to-report 	cls_et_cl_or	report	mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) >= 1]	end
to-report 	cls_vl_sq_bl	report	mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) >= 1]	end
to-report 	cls_vl_cl_bl	report	mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) >= 1]	end
to-report 	cls_vl_sq_or	report	mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) >= 1]	end
to-report 	cls_vl_cl_or	report	mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) >= 1]	end
to-report 	cls_den_sq_bl	report	mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8	end
to-report 	cls_den_cl_bl	report	mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8	end
to-report 	cls_den_sq_or	report	mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8	end
to-report 	cls_den_cl_or	report	mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8	end
to-report 	cls_et_bl	report	mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) >= 1]	end
to-report 	cls_et_or	report	mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) >= 1]	end
to-report 	cls_et_sq	report	mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) >= 1]	end
to-report 	cls_et_cl	report	mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) >= 1]	end
to-report 	cls_vl_bl	report	mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) >= 1]	end
to-report 	cls_vl_or	report	mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) >= 1]	end
to-report 	cls_vl_sq	report	mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) >= 1]	end
to-report 	cls_vl_cl	report	mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) >= 1]	end
to-report 	cls_den_bl	report	mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8	end
to-report 	cls_den_or	report	mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8	end
to-report 	cls_den_sq	report	mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8	end
to-report 	cls_den_cl	report	mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8	end
to-report 	mv_gl	report	count turtles with [movers? = TRUE] / count turtles	end
to-report 	mv_cl	report	count turtles with [movers? = TRUE and shape =  "circle"] / count turtles with [shape =  "circle"]	end
to-report 	mv_sq	report	count turtles with [movers? = TRUE and shape =  "square"] / count turtles with [shape =  "square"]	end
to-report 	mv_bl	report	count turtles with [movers? = TRUE and color =  blue] / count turtles with [color =  blue]	end
to-report 	mv_or	report	count turtles with [movers? = TRUE and color =  orange] / count turtles with [color =  orange]	end
to-report 	mv_sq_bl	report	count turtles with [movers? = TRUE and color =  blue and shape = "square"] / count turtles with [color =  blue and shape = "square"]	end
to-report 	mv_cl_bl	report	count turtles with [movers? = TRUE and color =  blue and shape = "circle"] / count turtles with [color =  blue and shape = "circle"]	end
to-report 	mv_sq_or	report	count turtles with [movers? = TRUE and color =  orange and shape = "square"] / count turtles with [color =  orange and shape = "square"]	end
to-report 	mv_cl_or	report	count turtles with [movers? = TRUE and color =  orange and shape = "circle"] / count turtles with [color =  orange and shape = "circle"]	end







@#$#@#$#@
GRAPHICS-WINDOW
230
23
687
481
-1
-1
8.804
1
10
1
1
1
0
1
1
1
-25
25
-25
25
0
0
1
ticks
30.0

SLIDER
96
31
217
64
density
density
0
99
70.0
1
1
NIL
HORIZONTAL

SLIDER
95
70
217
103
fraction_blue
fraction_blue
50
100
50.0
1
1
NIL
HORIZONTAL

BUTTON
535
489
598
522
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
602
489
665
522
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
704
327
961
471
segregation-global
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"eth-seg" 1.0 0 -5825686 true "" "plot percent-similar-eth"
"val-seg" 1.0 0 -10899396 true "" "plot percent-similar-val"

TEXTBOX
24
37
86
72
population parameters
11
0.0
1

SLIDER
20
112
112
145
circle_blue
circle_blue
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
114
113
218
146
circle_orange
circle_orange
0
100
50.0
1
1
NIL
HORIZONTAL

MONITOR
343
487
414
532
circle_blue
count turtles with [shape = \"circle\" and color = blue] / count turtles
2
1
11

MONITOR
343
538
415
583
square_bue
count turtles with [shape = \"square\" and color = blue] / count turtles
2
1
11

MONITOR
420
487
501
532
circle_orange
count turtles with [shape = \"circle\" and color = orange] / count turtles
2
1
11

MONITOR
418
537
502
582
square_orange
count turtles with [shape = \"square\" and color = orange] / count turtles
2
1
11

MONITOR
232
486
307
531
local/minority
count turtles with [color = blue] / count turtles
2
1
11

MONITOR
196
535
256
580
circle_%
count turtles with [shape = \"circle\"] / count turtles
2
1
11

PLOT
704
170
959
320
circle-blue (liberal local)
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ethnic" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = blue]"
"value" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = blue]"
"density" 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [shape = \"circle\"  and color = blue] / 8"

PLOT
703
11
962
161
square-blue (conservative local)
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ethnic" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = blue]"
"value" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = blue]"
"density" 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [shape = \"square\"  and color = blue] / 8"

PLOT
971
12
1221
162
square-orange (conservative minority)
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"eth" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = orange]"
"val" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = orange]"
"density" 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [shape = \"square\"  and color = orange] / 8"

PLOT
969
170
1222
320
circle-orange (liberal minority)
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ethnic" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = orange]"
"value" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and  shape = \"circle\"  and color = orange]"
"density" 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [shape = \"circle\"  and color = orange] / 8"

MONITOR
1226
10
1289
55
eth-sq-bl
mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = blue]
2
1
11

MONITOR
1226
60
1291
105
eth-sq-or
mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = orange]
2
1
11

MONITOR
1291
10
1351
55
val-sq-bl
mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\"  and color = blue]
2
1
11

MONITOR
1294
59
1357
104
val-sq-or
mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\"  and color = orange]
2
1
11

MONITOR
1225
171
1283
216
eth-cl-bl
mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = blue]
2
1
11

MONITOR
1286
171
1343
216
val-cl-bl
mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\"  and color = blue]
2
1
11

MONITOR
1226
221
1283
266
eth-cl-or
mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = orange]
2
1
11

MONITOR
1286
220
1344
265
val-cl-or
mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\"  and color = orange]
2
1
11

MONITOR
964
327
1021
372
eth-seg
percent-similar-eth
2
1
11

MONITOR
965
377
1022
422
val-seg
percent-similar-val
2
1
11

MONITOR
261
537
332
582
square_%
count turtles with [shape = \"square\"] / count turtles
2
1
11

MONITOR
512
532
601
577
prop_minority
count turtles with [color = orange] / count turtles
2
1
11

MONITOR
604
532
691
577
prop_local
count turtles with [color = blue] / count turtles
2
1
11

SLIDER
128
407
220
440
eth_lib
eth_lib
0.1
1
0.1
0.1
1
NIL
HORIZONTAL

SLIDER
127
260
219
293
val_con
val_con
0.1
1
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
7
509
180
542
determinism
determinism
0
50
20.0
1
1
NIL
HORIZONTAL

SLIDER
72
300
183
333
dominant_con
dominant_con
0
1
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
65
450
177
483
dominant_lib
dominant_lib
0
1
0.5
0.1
1
NIL
HORIZONTAL

TEXTBOX
17
547
160
589
* not choose peak = 0 with single-peaked function (division by 0, stops machine)
11
0.0
1

TEXTBOX
20
163
122
191
dominant preference weight
11
0.0
1

TEXTBOX
163
168
190
186
peak
11
0.0
1

TEXTBOX
25
191
103
219
conservatives\nethnic-oriented
11
0.0
1

TEXTBOX
24
337
106
365
liberals\nvalue-oriented
11
0.0
1

PLOT
1026
325
1226
475
movers
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"movers" 1.0 0 -16777216 true "" "plot (count turtles with [movers? = TRUE] / count turtles)"

MONITOR
1231
327
1288
372
movers
count turtles with [movers? = TRUE]
2
1
11

PLOT
704
473
1010
628
utility function
NIL
NIL
0.0
100.0
0.0
1.0
true
true
"" ""
PENS
"_cons-eth_" 1.0 0 -2674135 true "let l n-values 101 [ i -> i]\n\nforeach l  [\n  i -> plot ifelse-value (i <= (eth_con * 100)) [ (i / (eth_con * 100))][ \n precision(  (2 - M_con_dom) + ( ((M_con_dom - 1) * i) / (eth_con * 100))   )3]\n ]\n\n" ""
"..cons-val.." 1.0 2 -2674135 true "let l n-values 101 [ i -> i]\n\n foreach l  [\n  i -> plot ifelse-value (i <= (val_con * 100)) [ (i / (val_con * 100))][ \n precision(  (2 - M_con_sec) + ( ((M_con_sec - 1) * i) / (val_con * 100))   )3]\n ]\n\n" ""
"_lib-eth_" 1.0 0 -10899396 true "let l n-values 101 [ i -> i]\n \n foreach l  [\n  i -> plot ifelse-value (i <= (eth_lib * 100)) [ (i / (eth_lib * 100))][ \n precision(  (2 - M_lib_sec) + ( ((M_lib_sec - 1) * i) / (eth_lib * 100))   )3]\n ]\n \n" ""
"..lib-val.." 1.0 2 -10899396 true "let l n-values 101 [ i -> i]\n\nforeach l  [\n  i -> plot ifelse-value (i <= (val_lib * 100)) [ (i / (val_lib * 100))][ \n precision(  (2 - M_lib_dom) + ( ((M_lib_dom - 1) * i) / (val_lib * 100))   )3]\n ]\n\n" ""

SLIDER
10
260
122
293
M_con_sec
M_con_sec
0
1
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
6
408
118
441
M_lib_sec
M_lib_sec
0
1
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
127
223
219
256
eth_con
eth_con
0.1
1
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
129
372
221
405
val_lib
val_lib
0.1
1
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
11
224
123
257
M_con_dom
M_con_dom
0
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
6
370
118
403
M_lib_dom
M_lib_dom
0
1
1.0
0.1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

CHECK CODE!!
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="eth_lib" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>et_gl</metric>
    <metric>vl_gl</metric>
    <metric>den_gl</metric>
    <metric>et_sq</metric>
    <metric>et_cl</metric>
    <metric>vl_sq</metric>
    <metric>vl_cl</metric>
    <metric>den_sq</metric>
    <metric>den_cl</metric>
    <metric>et_bl</metric>
    <metric>et_or</metric>
    <metric>vl_bl</metric>
    <metric>vl_or</metric>
    <metric>den_bl</metric>
    <metric>den_or</metric>
    <metric>et_sq_bl</metric>
    <metric>et_cl_bl</metric>
    <metric>et_sq_or</metric>
    <metric>et_cl_or</metric>
    <metric>vl_sq_bl</metric>
    <metric>vl_cl_bl</metric>
    <metric>vl_sq_or</metric>
    <metric>vl_cl_or</metric>
    <metric>den_sq_bl</metric>
    <metric>den_sq_or</metric>
    <metric>den_cl_bl</metric>
    <metric>den_cl_or</metric>
    <metric>cls_et_sq_bl</metric>
    <metric>cls_et_cl_bl</metric>
    <metric>cls_et_sq_or</metric>
    <metric>cls_et_cl_or</metric>
    <metric>cls_vl_sq_bl</metric>
    <metric>cls_vl_cl_bl</metric>
    <metric>cls_vl_sq_or</metric>
    <metric>cls_vl_cl_or</metric>
    <metric>cls_den_sq_bl</metric>
    <metric>cls_den_cl_bl</metric>
    <metric>cls_den_sq_or</metric>
    <metric>cls_den_cl_or</metric>
    <metric>cls_et_bl</metric>
    <metric>cls_et_or</metric>
    <metric>cls_et_sq</metric>
    <metric>cls_et_cl</metric>
    <metric>cls_vl_bl</metric>
    <metric>cls_vl_or</metric>
    <metric>cls_vl_sq</metric>
    <metric>cls_vl_cl</metric>
    <metric>cls_den_bl</metric>
    <metric>cls_den_or</metric>
    <metric>cls_den_sq</metric>
    <metric>cls_den_cl</metric>
    <metric>mv_gl</metric>
    <metric>mv_cl</metric>
    <metric>mv_sq</metric>
    <metric>mv_bl</metric>
    <metric>mv_or</metric>
    <metric>mv_sq_bl</metric>
    <metric>mv_cl_bl</metric>
    <metric>mv_sq_or</metric>
    <metric>mv_cl_or</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fraction_blue">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="circle_blue">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="circle_orange">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant_con">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_con_dom">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_con_sec">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant_lib">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_lib_dom">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_lib_sec">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="eth_lib" first="0.1" step="0.1" last="1"/>
    <enumeratedValueSet variable="determinism">
      <value value="1"/>
      <value value="5"/>
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="int_lib" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>et_gl</metric>
    <metric>vl_gl</metric>
    <metric>den_gl</metric>
    <metric>et_sq</metric>
    <metric>et_cl</metric>
    <metric>vl_sq</metric>
    <metric>vl_cl</metric>
    <metric>den_sq</metric>
    <metric>den_cl</metric>
    <metric>et_bl</metric>
    <metric>et_or</metric>
    <metric>vl_bl</metric>
    <metric>vl_or</metric>
    <metric>den_bl</metric>
    <metric>den_or</metric>
    <metric>et_sq_bl</metric>
    <metric>et_cl_bl</metric>
    <metric>et_sq_or</metric>
    <metric>et_cl_or</metric>
    <metric>vl_sq_bl</metric>
    <metric>vl_cl_bl</metric>
    <metric>vl_sq_or</metric>
    <metric>vl_cl_or</metric>
    <metric>den_sq_bl</metric>
    <metric>den_sq_or</metric>
    <metric>den_cl_bl</metric>
    <metric>den_cl_or</metric>
    <metric>cls_et_sq_bl</metric>
    <metric>cls_et_cl_bl</metric>
    <metric>cls_et_sq_or</metric>
    <metric>cls_et_cl_or</metric>
    <metric>cls_vl_sq_bl</metric>
    <metric>cls_vl_cl_bl</metric>
    <metric>cls_vl_sq_or</metric>
    <metric>cls_vl_cl_or</metric>
    <metric>cls_den_sq_bl</metric>
    <metric>cls_den_cl_bl</metric>
    <metric>cls_den_sq_or</metric>
    <metric>cls_den_cl_or</metric>
    <metric>cls_et_bl</metric>
    <metric>cls_et_or</metric>
    <metric>cls_et_sq</metric>
    <metric>cls_et_cl</metric>
    <metric>cls_vl_bl</metric>
    <metric>cls_vl_or</metric>
    <metric>cls_vl_sq</metric>
    <metric>cls_vl_cl</metric>
    <metric>cls_den_bl</metric>
    <metric>cls_den_or</metric>
    <metric>cls_den_sq</metric>
    <metric>cls_den_cl</metric>
    <metric>mv_gl</metric>
    <metric>mv_cl</metric>
    <metric>mv_sq</metric>
    <metric>mv_bl</metric>
    <metric>mv_or</metric>
    <metric>mv_sq_bl</metric>
    <metric>mv_cl_bl</metric>
    <metric>mv_sq_or</metric>
    <metric>mv_cl_or</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fraction_blue">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="circle_blue">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="circle_orange">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant_con">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_con_dom">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_con_sec">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant_lib">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_lib_dom">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib">
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_lib_sec">
      <value value="0"/>
      <value value="0.1"/>
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib">
      <value value="0.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="determinism" first="0" step="1" last="20"/>
  </experiment>
  <experiment name="int_con" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>et_gl</metric>
    <metric>vl_gl</metric>
    <metric>den_gl</metric>
    <metric>et_sq</metric>
    <metric>et_cl</metric>
    <metric>vl_sq</metric>
    <metric>vl_cl</metric>
    <metric>den_sq</metric>
    <metric>den_cl</metric>
    <metric>et_bl</metric>
    <metric>et_or</metric>
    <metric>vl_bl</metric>
    <metric>vl_or</metric>
    <metric>den_bl</metric>
    <metric>den_or</metric>
    <metric>et_sq_bl</metric>
    <metric>et_cl_bl</metric>
    <metric>et_sq_or</metric>
    <metric>et_cl_or</metric>
    <metric>vl_sq_bl</metric>
    <metric>vl_cl_bl</metric>
    <metric>vl_sq_or</metric>
    <metric>vl_cl_or</metric>
    <metric>den_sq_bl</metric>
    <metric>den_sq_or</metric>
    <metric>den_cl_bl</metric>
    <metric>den_cl_or</metric>
    <metric>cls_et_sq_bl</metric>
    <metric>cls_et_cl_bl</metric>
    <metric>cls_et_sq_or</metric>
    <metric>cls_et_cl_or</metric>
    <metric>cls_vl_sq_bl</metric>
    <metric>cls_vl_cl_bl</metric>
    <metric>cls_vl_sq_or</metric>
    <metric>cls_vl_cl_or</metric>
    <metric>cls_den_sq_bl</metric>
    <metric>cls_den_cl_bl</metric>
    <metric>cls_den_sq_or</metric>
    <metric>cls_den_cl_or</metric>
    <metric>cls_et_bl</metric>
    <metric>cls_et_or</metric>
    <metric>cls_et_sq</metric>
    <metric>cls_et_cl</metric>
    <metric>cls_vl_bl</metric>
    <metric>cls_vl_or</metric>
    <metric>cls_vl_sq</metric>
    <metric>cls_vl_cl</metric>
    <metric>cls_den_bl</metric>
    <metric>cls_den_or</metric>
    <metric>cls_den_sq</metric>
    <metric>cls_den_cl</metric>
    <metric>mv_gl</metric>
    <metric>mv_cl</metric>
    <metric>mv_sq</metric>
    <metric>mv_bl</metric>
    <metric>mv_or</metric>
    <metric>mv_sq_bl</metric>
    <metric>mv_cl_bl</metric>
    <metric>mv_sq_or</metric>
    <metric>mv_cl_or</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fraction_blue">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="circle_blue">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="circle_orange">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant_con">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_con_dom">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con">
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_con_sec">
      <value value="0"/>
      <value value="0.1"/>
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant_lib">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_lib_dom">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_lib_sec">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="determinism" first="0" step="1" last="20"/>
  </experiment>
  <experiment name="baseline" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>et_gl</metric>
    <metric>vl_gl</metric>
    <metric>den_gl</metric>
    <metric>et_sq</metric>
    <metric>et_cl</metric>
    <metric>vl_sq</metric>
    <metric>vl_cl</metric>
    <metric>den_sq</metric>
    <metric>den_cl</metric>
    <metric>et_bl</metric>
    <metric>et_or</metric>
    <metric>vl_bl</metric>
    <metric>vl_or</metric>
    <metric>den_bl</metric>
    <metric>den_or</metric>
    <metric>et_sq_bl</metric>
    <metric>et_cl_bl</metric>
    <metric>et_sq_or</metric>
    <metric>et_cl_or</metric>
    <metric>vl_sq_bl</metric>
    <metric>vl_cl_bl</metric>
    <metric>vl_sq_or</metric>
    <metric>vl_cl_or</metric>
    <metric>den_sq_bl</metric>
    <metric>den_sq_or</metric>
    <metric>den_cl_bl</metric>
    <metric>den_cl_or</metric>
    <metric>cls_et_sq_bl</metric>
    <metric>cls_et_cl_bl</metric>
    <metric>cls_et_sq_or</metric>
    <metric>cls_et_cl_or</metric>
    <metric>cls_vl_sq_bl</metric>
    <metric>cls_vl_cl_bl</metric>
    <metric>cls_vl_sq_or</metric>
    <metric>cls_vl_cl_or</metric>
    <metric>cls_den_sq_bl</metric>
    <metric>cls_den_cl_bl</metric>
    <metric>cls_den_sq_or</metric>
    <metric>cls_den_cl_or</metric>
    <metric>cls_et_bl</metric>
    <metric>cls_et_or</metric>
    <metric>cls_et_sq</metric>
    <metric>cls_et_cl</metric>
    <metric>cls_vl_bl</metric>
    <metric>cls_vl_or</metric>
    <metric>cls_vl_sq</metric>
    <metric>cls_vl_cl</metric>
    <metric>cls_den_bl</metric>
    <metric>cls_den_or</metric>
    <metric>cls_den_sq</metric>
    <metric>cls_den_cl</metric>
    <metric>mv_gl</metric>
    <metric>mv_cl</metric>
    <metric>mv_sq</metric>
    <metric>mv_bl</metric>
    <metric>mv_or</metric>
    <metric>mv_sq_bl</metric>
    <metric>mv_cl_bl</metric>
    <metric>mv_sq_or</metric>
    <metric>mv_cl_or</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fraction_blue">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="circle_blue">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="circle_orange">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant_con">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_con_dom">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="eth_con" first="0.1" step="0.1" last="1"/>
    <enumeratedValueSet variable="M_con_sec">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant_lib">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_lib_dom">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="val_lib" first="0.1" step="0.1" last="1"/>
    <enumeratedValueSet variable="M_lib_sec">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="determinism">
      <value value="5"/>
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="both_sec_1" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>et_gl</metric>
    <metric>vl_gl</metric>
    <metric>den_gl</metric>
    <metric>et_sq</metric>
    <metric>et_cl</metric>
    <metric>vl_sq</metric>
    <metric>vl_cl</metric>
    <metric>den_sq</metric>
    <metric>den_cl</metric>
    <metric>et_bl</metric>
    <metric>et_or</metric>
    <metric>vl_bl</metric>
    <metric>vl_or</metric>
    <metric>den_bl</metric>
    <metric>den_or</metric>
    <metric>et_sq_bl</metric>
    <metric>et_cl_bl</metric>
    <metric>et_sq_or</metric>
    <metric>et_cl_or</metric>
    <metric>vl_sq_bl</metric>
    <metric>vl_cl_bl</metric>
    <metric>vl_sq_or</metric>
    <metric>vl_cl_or</metric>
    <metric>den_sq_bl</metric>
    <metric>den_sq_or</metric>
    <metric>den_cl_bl</metric>
    <metric>den_cl_or</metric>
    <metric>cls_et_sq_bl</metric>
    <metric>cls_et_cl_bl</metric>
    <metric>cls_et_sq_or</metric>
    <metric>cls_et_cl_or</metric>
    <metric>cls_vl_sq_bl</metric>
    <metric>cls_vl_cl_bl</metric>
    <metric>cls_vl_sq_or</metric>
    <metric>cls_vl_cl_or</metric>
    <metric>cls_den_sq_bl</metric>
    <metric>cls_den_cl_bl</metric>
    <metric>cls_den_sq_or</metric>
    <metric>cls_den_cl_or</metric>
    <metric>cls_et_bl</metric>
    <metric>cls_et_or</metric>
    <metric>cls_et_sq</metric>
    <metric>cls_et_cl</metric>
    <metric>cls_vl_bl</metric>
    <metric>cls_vl_or</metric>
    <metric>cls_vl_sq</metric>
    <metric>cls_vl_cl</metric>
    <metric>cls_den_bl</metric>
    <metric>cls_den_or</metric>
    <metric>cls_den_sq</metric>
    <metric>cls_den_cl</metric>
    <metric>mv_gl</metric>
    <metric>mv_cl</metric>
    <metric>mv_sq</metric>
    <metric>mv_bl</metric>
    <metric>mv_or</metric>
    <metric>mv_sq_bl</metric>
    <metric>mv_cl_bl</metric>
    <metric>mv_sq_or</metric>
    <metric>mv_cl_or</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fraction_blue">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="circle_blue">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="circle_orange">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant_con">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_con_dom">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_con_sec">
      <value value="0"/>
      <value value="0.1"/>
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant_lib">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_lib_dom">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_lib_sec">
      <value value="0"/>
      <value value="0.1"/>
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib">
      <value value="0.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="determinism" first="0" step="1" last="20"/>
  </experiment>
  <experiment name="both_sec_05" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>et_gl</metric>
    <metric>vl_gl</metric>
    <metric>den_gl</metric>
    <metric>et_sq</metric>
    <metric>et_cl</metric>
    <metric>vl_sq</metric>
    <metric>vl_cl</metric>
    <metric>den_sq</metric>
    <metric>den_cl</metric>
    <metric>et_bl</metric>
    <metric>et_or</metric>
    <metric>vl_bl</metric>
    <metric>vl_or</metric>
    <metric>den_bl</metric>
    <metric>den_or</metric>
    <metric>et_sq_bl</metric>
    <metric>et_cl_bl</metric>
    <metric>et_sq_or</metric>
    <metric>et_cl_or</metric>
    <metric>vl_sq_bl</metric>
    <metric>vl_cl_bl</metric>
    <metric>vl_sq_or</metric>
    <metric>vl_cl_or</metric>
    <metric>den_sq_bl</metric>
    <metric>den_sq_or</metric>
    <metric>den_cl_bl</metric>
    <metric>den_cl_or</metric>
    <metric>cls_et_sq_bl</metric>
    <metric>cls_et_cl_bl</metric>
    <metric>cls_et_sq_or</metric>
    <metric>cls_et_cl_or</metric>
    <metric>cls_vl_sq_bl</metric>
    <metric>cls_vl_cl_bl</metric>
    <metric>cls_vl_sq_or</metric>
    <metric>cls_vl_cl_or</metric>
    <metric>cls_den_sq_bl</metric>
    <metric>cls_den_cl_bl</metric>
    <metric>cls_den_sq_or</metric>
    <metric>cls_den_cl_or</metric>
    <metric>cls_et_bl</metric>
    <metric>cls_et_or</metric>
    <metric>cls_et_sq</metric>
    <metric>cls_et_cl</metric>
    <metric>cls_vl_bl</metric>
    <metric>cls_vl_or</metric>
    <metric>cls_vl_sq</metric>
    <metric>cls_vl_cl</metric>
    <metric>cls_den_bl</metric>
    <metric>cls_den_or</metric>
    <metric>cls_den_sq</metric>
    <metric>cls_den_cl</metric>
    <metric>mv_gl</metric>
    <metric>mv_cl</metric>
    <metric>mv_sq</metric>
    <metric>mv_bl</metric>
    <metric>mv_or</metric>
    <metric>mv_sq_bl</metric>
    <metric>mv_cl_bl</metric>
    <metric>mv_sq_or</metric>
    <metric>mv_cl_or</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fraction_blue">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="circle_blue">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="circle_orange">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant_con">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_con_dom">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_con_sec">
      <value value="0"/>
      <value value="0.1"/>
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant_lib">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_lib_dom">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_lib_sec">
      <value value="0"/>
      <value value="0.1"/>
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib">
      <value value="0.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="determinism" first="0" step="1" last="20"/>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
