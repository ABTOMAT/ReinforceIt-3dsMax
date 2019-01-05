-- This script gives automatic tool for 3ds max
-- that can create lowpoly reinforcement bars uv-mapped to texture atlas

-- Made by Dmitry Maslov @ http://maslov.co
-- Skype: blitz3dproger
-- Telegram: @ABTOMAT
-- GitHub: ABTOMAT

-- January 2019.

	scriptVersion = "0.1"

	riVisualUVPickerDialogOpen = false
	riVisualUVPickerBmpSize = 512
	riVisualUVPickerBmp = bitmap riVisualUVPickerBmpSize riVisualUVPickerBmpSize color:(color 40 40 40)
	
	
	riVisualUVPickerPickUVMode = 0
	-- 0 = Pick side
	-- 1 = Pick cap
	
	riVisualUVPickerCurrentObject = undefined
	
	riVisualUVPickerMtlChangeCallback = undefined
	
	riVisualUVPickerMousePosStart = [0,0]
	riVisualUVPickerMouseDrawingFrame = false
	
	rollout riVisualUVPickerRollout "Visual UV Picker" 
	(		
		imgTag bmpTex bitmap:riVisualUVPickerBmp pos:[0,0] style:#bmp_stretch transparent:(color 68 68 68)
						
		label rules1 "Drag Left Mouse Button on the image to pick Pick Side UVs (Yellow)"
		label rules2 "Drag Right Mouse Button on the image to pick Pick Cap UVs (Green)"
		
		label placeHolder1 visible:false enabled:false
		
		label rules3 "Keyboard Entry"
		
		--label placeHolder2 visible:false enabled:false
		
		label rules4 "Side UVs" across:2
		label rules5 "Cap UVs" across:2
		
		--label placeHolder3 visible:false enabled:false
		
		-- UV
		
		spinner spnUvSideLU "Left U: " type:#float range:[0, 1, 0.5] scale:0.001 across:2
		spinner spnUvCapLU "Left U: " type:#float range:[0, 1, 0.5] scale:0.001 across:2
		
		spinner spnUvSideRU "Right U: " type:#float range:[0, 1, 0.5] scale:0.001 across:2
		spinner spnUvCapRU "Right U: " type:#float range:[0, 1, 0.5] scale:0.001 across:2
		
		spinner spnUvSideTV "Top V: " type:#float range:[0, 1, 0.5] scale:0.001 across:2
		spinner spnUvCapTV "Top V: " type:#float range:[0, 1, 0.5] scale:0.001 across:2
		
		spinner spnUvSideBV "Bottom V: " type:#float range:[0, 1, 0.5] scale:0.001 across:2
		spinner spnUvCapBV "Bottom V: " type:#float range:[0, 1, 0.5] scale:0.001 across:2

		hyperLink scriptpage "Script Homepage" color:(color 128 128 255) hoverColor:(color 200 200 255) visitedColor:(color 0 0 255) address:"https://github.com/ABTOMAT/ReinforceIt-3dsMax"
		hyperLink authorpage "by Dmitry Maslov" color:(color 128 128 255) hoverColor:(color 200 200 255) visitedColor:(color 0 0 255) address:"http://maslov.co/" across:2
		hyperLink patreonpage "support me on Patreon" color:(color 128 128 255) hoverColor:(color 200 200 255) visitedColor:(color 0 0 255) address:"https://www.patreon.com/ABTOMAT" across:2
		
		timer redrawUVClock "redrawUVClock" interval: 100
		
		on riVisualUVPickerRollout open do
		(
			callbacks.addscript #selectionSetChanged "riVisualUVPickerRollout.callbackSelectionChanged()" id:#riVisualUVPickerCallbacks

			riVisualUVPickerRollout.updateTextureBitmap()
			riVisualUVPickerRollout.updateSpinners()
		)
		
		on riVisualUVPickerRollout close do
		(
			riVisualUVPickerDialogOpen = false
			callbacks.removeScripts id:#riVisualUVPickerCallbacks
			
			--riVisualUVPickerMtlChangeCallback = undefined
			gc light:true
		)
		
		-- Translate values from spinners to object properties
		
		on spnUvSideLU changed val do	(if riVisualUVPickerRollout.isCurrentObject() then	riVisualUVPickerCurrentObject.uvSideLU = val)
		on spnUvSideRU changed val do	(if riVisualUVPickerRollout.isCurrentObject() then	riVisualUVPickerCurrentObject.uvSideRU = val)
		on spnUvSideTV changed val do	(if riVisualUVPickerRollout.isCurrentObject() then	riVisualUVPickerCurrentObject.uvSideTV = val)
		on spnUvSideBV changed val do	(if riVisualUVPickerRollout.isCurrentObject() then	riVisualUVPickerCurrentObject.uvSideBV = val)
		
		on spnUvCapLU changed val do	(if riVisualUVPickerRollout.isCurrentObject() then	riVisualUVPickerCurrentObject.uvCapLU = val)
		on spnUvCapRU changed val do	(if riVisualUVPickerRollout.isCurrentObject() then	riVisualUVPickerCurrentObject.uvCapRU = val)
		on spnUvCapTV changed val do	(if riVisualUVPickerRollout.isCurrentObject() then	riVisualUVPickerCurrentObject.uvCapTV = val)
		on spnUvCapBV changed val do	(if riVisualUVPickerRollout.isCurrentObject() then	riVisualUVPickerCurrentObject.uvCapBV = val)
		
		on bmpTex lbuttondown pos flags do
		(
			if riVisualUVPickerRollout.isCurrentObject() then
			(				
				riVisualUVPickerPickUVMode = 0
				
				riVisualUVPickerMousePosStart = pos					
				riVisualUVPickerMouseDrawingFrame = true
				
				riVisualUVPickerRollout.updateUVByMousePos pos pos
				riVisualUVPickerRollout.updateTextureBitmap()
			)
		)
		
		on bmpTex lbuttonup pos flags do
		(			
			if riVisualUVPickerRollout.isCurrentObject() then
			(
				riVisualUVPickerMouseDrawingFrame = false
				riVisualUVPickerRollout.updateUVByMousePos riVisualUVPickerMousePosStart pos
				
				riVisualUVPickerRollout.updateTextureBitmap()
			)
		)

		on bmpTex rbuttondown pos flags do
		(
			if riVisualUVPickerRollout.isCurrentObject() then
			(				
				riVisualUVPickerPickUVMode = 1
				
				riVisualUVPickerMousePosStart = pos					
				riVisualUVPickerMouseDrawingFrame = true
				
				riVisualUVPickerRollout.updateUVByMousePos pos pos
				riVisualUVPickerRollout.updateTextureBitmap()
			)
		)
		
		on bmpTex rbuttonup pos flags do
		(			
			if riVisualUVPickerRollout.isCurrentObject() then
			(
				riVisualUVPickerMouseDrawingFrame = false
				riVisualUVPickerRollout.updateUVByMousePos riVisualUVPickerMousePosStart pos
				
				riVisualUVPickerRollout.updateTextureBitmap()
			)
		)
		
		on bmpTex mouseover do
		(
			setSysCur #select
		)
		
		on bmpTex mouseout  do
		(
			setSysCur #arrow 
		)
		
		on redrawUVClock tick do
		(
			if riVisualUVPickerRollout.isCurrentObject() then
			(
				riVisualUVPickerRollout.drawUVRects()
			)
		)
		
		fn updateUVByMousePos startPos endPos =
		(
					local uStart = startPos.x/riVisualUVPickerBmpSize
					local vStart = 1 - (startPos.y/riVisualUVPickerBmpSize)
					local uEnd= endPos.x/riVisualUVPickerBmpSize
					local vEnd = 1 - (endPos.y/riVisualUVPickerBmpSize)

					if uStart > uEnd then
					(
						local tempVal = uStart
						uStart = uEnd
						uEnd = tempVal
					)
					
					if vStart > vEnd then
					(
						local tempVal = vStart
						vStart = vEnd
						vEnd = tempVal
					)
					
					
					case riVisualUVPickerPickUVMode of
					(
						0:
						(
							riVisualUVPickerCurrentObject.uvSideLU = uStart
							riVisualUVPickerCurrentObject.uvSideRU = uEnd
							riVisualUVPickerCurrentObject.uvSideTV = vStart
							riVisualUVPickerCurrentObject.uvSideBV = vEnd							
						)
						1:
						(
							riVisualUVPickerCurrentObject.uvCapLU = uStart
							riVisualUVPickerCurrentObject.uvCapRU = uEnd
							riVisualUVPickerCurrentObject.uvCapTV = vStart
							riVisualUVPickerCurrentObject.uvCapBV = vEnd							
						)
					)
					
					riVisualUVPickerRollout.updateSpinners()
					redrawViews()					
		)
		
		fn updateSpinners =
		(			
			if riVisualUVPickerRollout.isCurrentObject() then
			(
				spnUvSideLU.value = riVisualUVPickerCurrentObject.uvSideLU
				spnUvSideRU.value = riVisualUVPickerCurrentObject.uvSideRU
				spnUvSideTV.value = riVisualUVPickerCurrentObject.uvSideTV
				spnUvSideBV.value = riVisualUVPickerCurrentObject.uvSideBV
				
				spnUvCapLU.value = riVisualUVPickerCurrentObject.uvCapLU
				spnUvCapRU.value = riVisualUVPickerCurrentObject.uvCapRU
				spnUvCapTV.value = riVisualUVPickerCurrentObject.uvCapTV
				spnUvCapBV.value = riVisualUVPickerCurrentObject.uvCapBV
			)
		)
		
		fn callbackSelectionChanged =
		(
			destroyDialog riVisualUVPickerRollout
		)
		
		fn updateTextureBitmap =
		(
			local hasDiffuseMap = false
			
			if riVisualUVPickerRollout.isCurrentObject() then
			(
				if riVisualUVPickerCurrentObject.material != undefined then
				(
					if riVisualUVPickerCurrentObject.material.diffuseMap != undefined then
					(
						hasDiffuseMap = true
					)
				)
			)
			
			if  hasDiffuseMap then
			(
				copy riVisualUVPickerCurrentObject.material.diffuseMap.bitmap riVisualUVPickerBmp
			)
			else
			(
				--MessageBox "To use this function a material with diffuse texture is required!"
				
				free riVisualUVPickerBmp
				riVisualUVPickerBmp = bitmap riVisualUVPickerBmpSize riVisualUVPickerBmpSize color:(color 40 40 40)
			)
			
			
			if riVisualUVPickerRollout.isCurrentObject() then
			(
				riVisualUVPickerRollout.drawUVRects()
			)
			
			
			bmpTex.bitmap = riVisualUVPickerBmp
			
		)
		
		fn isCurrentObject =
		(
			if riVisualUVPickerCurrentObject != undefined then
			(
				if ((classof riVisualUVPickerCurrentObject) as string) == "RIBar" then
				(
					return true
				)
			)
			return false
		)
		
		fn drawUVRects =
		(
	riVisualUVPickerRollout.drawStripedRect riVisualUVPickerBmp 6 #(color 255 255 0) #(color 0 0 0) (riVisualUVPickerCurrentObject.uvSideLU*riVisualUVPickerBmpSize) ((1-riVisualUVPickerCurrentObject.uvSideTV)*riVisualUVPickerBmpSize) (riVisualUVPickerCurrentObject.uvSideRU*riVisualUVPickerBmpSize) ((1-riVisualUVPickerCurrentObject.uvSideBV)*riVisualUVPickerBmpSize)
	riVisualUVPickerRollout.drawStripedRect riVisualUVPickerBmp 6 #(color 0 255 0) #(color 0 0 0) (riVisualUVPickerCurrentObject.uvCapLU*riVisualUVPickerBmpSize) ((1-riVisualUVPickerCurrentObject.uvCapTV)*riVisualUVPickerBmpSize) (riVisualUVPickerCurrentObject.uvCapRU*riVisualUVPickerBmpSize) ((1-riVisualUVPickerCurrentObject.uvCapBV)*riVisualUVPickerBmpSize)
		)
		
		fn drawStripedRect bmpBitmap stripLen color1 color2 xStart yStart xEnd yEnd =
		(
			local phase = timeStamp()
			phase = mod (phase*0.025) (stripLen*2)
			
			if xStart > xEnd then
			(
				local tempVal = xStart
				xStart = xEnd
				xEnd = tempVal
			)
			
			if yStart > yEnd then
			(
				local tempVal = yStart
				yStart = yEnd
				yEnd = tempVal
			)
			
			local currColor = color1
					
			for x=xStart to xEnd do
			(
				if ((mod (x+phase) (stripLen*2)) >= stripLen) then
				(
					currColor = color1
				)
				else
				(
					currColor = color2
				)
				
				setPixels bmpBitmap [x, yStart] currColor
				setPixels bmpBitmap [x, yEnd] currColor
			)
			
			for y=yStart to yEnd do
			(
				if ((mod (y+phase) (stripLen*2)) >= stripLen) then
				(
					currColor = color1
				)
				else
				(
					currColor = color2
				)
				
				setPixels bmpBitmap [xStart, y] currColor
				setPixels bmpBitmap [xEnd, y] currColor
			)
			
		)
	)
	
plugin simpleObject RIBar
	name:"RI Bar"
	category:"ReinforceIt!"
	classID:#(0x71966078, 0x81278a01)
(
	
	parameters main rollout:params
	(
		radius default:10 type:#worldUnits ui:spnRadius
		height default:20 type:#worldUnits ui:spnHeight
		
		sectionHeight default:10 type:#worldUnits ui:spnSectionHeight
		
		numSegs default:1 type:#integer
		
		-- UV
		
		uvSideLU default:0 type:#float --ui:spnUvSideLU
		uvSideRU default:0 type:#float --ui:spnUvSideRU
		uvSideTV default:0 type:#float --ui:spnUvSideTV
		uvSideBV default:0 type:#float --ui:spnUvSideBV
		
		uvCapLU default:0 type:#float --ui:spnUvCapLU
		uvCapRU default:0 type:#float --ui:spnUvCapRU
		uvCapTV default:0 type:#float --ui:spnUvCapTV
		uvCapBV default:0 type:#float --ui:spnUvCapBV
		
		-- Deform
		
		deform default:false type:#boolean ui:chxDeform
		
		deformX default:0.25 type:#worldUnits ui:spnDeformX
		deformY default:0 type:#worldUnits ui:spnDeformY
		deformFrequency default:16 type:#worldUnits ui:spnDeformFrequency
		
		bottomCap default:true type:#boolean ui:chxBottomCap
		topCap default:true type:#boolean ui:chxTopCap
	)
	
	rollout params "Parameters"
	(
		spinner spnRadius "Radius: " type:#worldUnits range:[1e-9, 1e9, 10]
		spinner spnHeight "Height: " type:#worldUnits range:[-1e9, 1e9, 20]
		spinner spnSectionHeight "Section Height: " type:#worldUnits range:[0.1, 1e9, 20]
		
		-- UV
		
		/*
		
		-- -- Side
		
		spinner spnUvSideLU "Side UV Left U: " type:#float range:[0, 1, 0.5]
		spinner spnUvSideRU "Side UV Right U: " type:#float range:[0, 1, 0.5]
		
		spinner spnUvSideTV "Side UV Top V: " type:#float range:[0, 1, 0.5]
		spinner spnUvSideBV "Side UV Bot V: " type:#float range:[0, 1, 0.5]
		
		-- -- Cap
		
		spinner spnUvCapLU "Cap UV Left U: " type:#float range:[0, 1, 0.5]
		spinner spnUvCapRU "Cap UV Right U: " type:#float range:[0, 1, 0.5]
		
		spinner spnUvCapTV "Cap UV Top V: " type:#float range:[0, 1, 0.5]
		spinner spnUvCapBV "Cap UV Bot V: " type:#float range:[0, 1, 0.5]
		
		*/
		
		-- -- Visual Picker
		
		label placeHolder1 visible:false enabled:false
		button btnPickUVs "Pick UVs"
		label placeHolder2 visible:false enabled:false
		
		-- Deform
		
		checkBox chxDeform "Deform"
		
		spinner spnDeformX "X: " type:#worldUnits range:[-1e9, 1e9, 10]
		spinner spnDeformY "Y: " type:#worldUnits range:[-1e9, 1e9, 10]
		spinner spnDeformFrequency "Frequency: " type:#worldUnits range:[1e-9, 1e9, 10]
		
		checkBox chxBottomCap "Bottom Cap"
		checkBox chxTopCap "Top Cap"
		
		on btnPickUVs pressed do
		(
			if riVisualUVPickerDialogOpen == false then
			(
				if selection.count == 1 then
				(
					if (classof selection[1]) == RIBar then
					(
						riVisualUVPickerCurrentObject = selection[1]
						riVisualUVPickerDialogOpen = createdialog riVisualUVPickerRollout riVisualUVPickerBmpSize (riVisualUVPickerBmpSize + 220)
					)
				)
			)
			else
			(
				destroyDialog riVisualUVPickerRollout
				riVisualUVPickerDialogOpen = false
			)
		)
		
		on params open do
		(
			--btnPickUVSide.checked = riVisualUVPickerDialogOpen
		)
	)
	
	tool create numPoints:3
	(
		on mousePoint click do if click == 1 do
		(
			nodeTM.translation = gridPoint
			height = 0
		)

		on mouseMove click do case click of
		(
			2:
			(
				radius = (gridDist.x^2 + gridDist.y^2)^.5
				
				this.recalculateSegs([1,1,1])
			)
			3: height = gridDist.z
		)
	)
	
	on buildMesh do
	(
		
		local vertArr = #()
		local faceArr = #()

		local sectionHeightActual = height/numSegs

		for i=0 to numSegs do
		(		
			this.addLoop &vertArr &faceArr (i*sectionHeightActual)
		)
				
		-- Make caps
		
		if bottomCap then
		(
			append faceArr [1, 2, 3]
			append faceArr [3, 4, 1]
		)
		
		if topCap then
		(
			local initVertCount = vertArr.count
			local ivc = initVertCount
			
			append faceArr [ivc-2, ivc-3, ivc+0]
			append faceArr [ivc+0, ivc-1, ivc-2]
		)
		
		setMesh mesh vertices:vertArr faces:faceArr
		
		-- Quadrify
		
		local numFaces = faceArr.count
				
		local numSegmentFaces  = numFaces
		if bottomCap then numSegmentFaces = numSegmentFaces-2
		if topCap then numSegmentFaces = numSegmentFaces-2
		
		for faceIndex=1 to numFaces do
		(		
			setEdgeVis mesh faceIndex 3 false
			
			-- Set Smoothing Groups
			
			if faceIndex <= numSegmentFaces then
			(
				case (mod faceIndex 8) of
				(
					1: smoothGroup = 1
					2: smoothGroup = 1
					
					3: smoothGroup = 2
					4: smoothGroup = 2
					
					5: smoothGroup = 1
					6: smoothGroup = 1
					
					7: smoothGroup = 2
					0: smoothGroup = 2
					
					default: smoothGroup = 0
				)
			)
			else
			(
				smoothGroup = 3
			)
			
			smoothGroup = 2^(smoothGroup-1)			
			setFaceSmoothGroup mesh faceIndex smoothGroup
		)
		
		-- Set UVs
		
		meshop.setNumMaps mesh 2
		
		local numMapVerts = numSegs*16
		if bottomCap then numMapVerts = numMapVerts + 8
		if topCap then numMapVerts = numMapVerts + 8
		
		meshop.setNumMapVerts mesh 1 numMapVerts
		
		-- Segments
		
		/*
		local segBLCornerUV = [0.09475,0.45926,0]
		local segBRCornerUV = [0.27811,0.45926,0]
		local segTLCornerUV = [0.09475,0.48531,0]
		local segTRCornerUV = [0.27811,0.48531,0]
		*/
		
		local sideBLCornerUV = [uvSideLU,uvSideBV,0]
		local sideBRCornerUV = [uvSideRU,uvSideBV,0]
		local sideTLCornerUV = [uvSideLU,uvSideTV,0]
		local sideTRCornerUV = [uvSideRU,uvSideTV,0]
		
		for i=0 to numSegs-1 do
		(
			local initFaceIndex = i*8+1
			local ifi = initFaceIndex
				
			local initMapVertIndex = i*16+1
			local imvi = initMapVertIndex
			
			local isVertTex = false -- for future
			
			-- UV for each side
			
			if isVertTex then
			(
				for j=0 to 3 do
				(
					meshop.setMapVert mesh 1 (imvi+j*4+0) sideBLCornerUV
					meshop.setMapVert mesh 1 (imvi+j*4+1) sideTLCornerUV
					meshop.setMapVert mesh 1 (imvi+j*4+2) sideTRCornerUV
					meshop.setMapVert mesh 1 (imvi+j*4+3) sideBRCornerUV
				)
			)
			else
			(
				for j=0 to 3 do
				(
					meshop.setMapVert mesh 1 (imvi+j*4+0) sideTLCornerUV
					meshop.setMapVert mesh 1 (imvi+j*4+1) sideTRCornerUV
					meshop.setMapVert mesh 1 (imvi+j*4+2) sideBRCornerUV
					meshop.setMapVert mesh 1 (imvi+j*4+3) sideBLCornerUV
				)
			)
			
			meshop.setMapFace mesh 1 (ifi+0) [imvi+0+3, imvi+0+2, imvi+0+1]
			meshop.setMapFace mesh 1 (ifi+1) [imvi+0+1, imvi+0+0, imvi+0+3]
			
			meshop.setMapFace mesh 1 (ifi+2) [imvi+4+3, imvi+4+2, imvi+4+1]
			meshop.setMapFace mesh 1 (ifi+3) [imvi+4+1, imvi+4+0, imvi+4+3]
				
			meshop.setMapFace mesh 1 (ifi+4) [imvi+8+3, imvi+8+2, imvi+8+1]
			meshop.setMapFace mesh 1 (ifi+5) [imvi+8+1, imvi+8+0, imvi+8+3]
				
			meshop.setMapFace mesh 1 (ifi+6) [imvi+12+3, imvi+12+2, imvi+12+1]
			meshop.setMapFace mesh 1 (ifi+7) [imvi+12+1, imvi+12+0, imvi+12+3]				
		)
		
		-- Caps
		
		/*
		local capBLCornerUV = [0.25035,0.45926,0]
		local capBRCornerUV = [0.27811,0.45926,0]
		local capTLCornerUV = [0.25035,0.48531,0]
		local capTRCornerUV = [0.27811,0.48531,0]
		*/		
		
		local capBLCornerUV = [uvCapLU,uvCapBV,0]
		local capBRCornerUV = [uvCapRU,uvCapBV,0]
		local capTLCornerUV = [uvCapLU,uvCapTV,0]
		local capTRCornerUV = [uvCapRU,uvCapTV,0]
				
		local initFaceIndex = numSegs*8+1
		local ifi = initFaceIndex
				
		local initMapVertIndex = numSegs*16+1
		local imvi = initMapVertIndex
		
		if bottomCap then
		(
			meshop.setMapVert mesh 1 (imvi+0) capBLCornerUV
			meshop.setMapVert mesh 1 (imvi+1) capTLCornerUV
			meshop.setMapVert mesh 1 (imvi+2) capTRCornerUV
			meshop.setMapVert mesh 1 (imvi+3) capBRCornerUV
			
			meshop.setMapFace mesh 1 (ifi+0) [imvi+3, imvi+2, imvi+1]
			meshop.setMapFace mesh 1 (ifi+1) [imvi+1, imvi+0, imvi+3]	
			
			ifi = ifi+2
			imvi = imvi + 4
		)
		
		if topCap then
		(
			meshop.setMapVert mesh 1 (imvi+0) capBLCornerUV
			meshop.setMapVert mesh 1 (imvi+1) capTLCornerUV
			meshop.setMapVert mesh 1 (imvi+2) capTRCornerUV
			meshop.setMapVert mesh 1 (imvi+3) capBRCornerUV
			
			meshop.setMapFace mesh 1 (ifi+0) [imvi+3, imvi+2, imvi+1]
			meshop.setMapFace mesh 1 (ifi+1) [imvi+1, imvi+0, imvi+3]	
			
			ifi = ifi+2
			imvi = imvi + 4
		)
		
		-- Flip if height is negative
		
		if height < 0 then meshop.flipNormals mesh #{1..mesh.numfaces}
	)
	
	fn addLoop &vertArr &faceArr z =
	(
		local initVertCount = vertArr.count
		local ivc = initVertCount
		
		local deformFactorX = 0
		local deformFactorY = 0
		
		if deform then
		(
			deformFactorX = deformX*(sin (z*deformFrequency))*radius
			deformFactorY = deformY*(cos (z*deformFrequency))*radius
		)
		
		append vertArr [-radius+deformFactorX,-radius+deformFactorY, z]
		append vertArr [-radius+deformFactorX, radius+deformFactorY, z]
		append vertArr [ radius+deformFactorX, radius+deformFactorY, z]
		append vertArr [ radius+deformFactorX,-radius+deformFactorY, z]
		
		if ivc >= 4 then
		(
			append faceArr [ivc-3, ivc+1, ivc+2]
			append faceArr [ivc+2, ivc-2, ivc-3]
			
			append faceArr [ivc+0, ivc+4, ivc+1]
			append faceArr [ivc+1, ivc-3, ivc+0]
			
			append faceArr [ivc-1, ivc+3, ivc+4]
			append faceArr [ivc+4, ivc-0, ivc-1]
			
			append faceArr [ivc-2, ivc+2, ivc+3]
			append faceArr [ivc+3, ivc-1, ivc-2]
		)
		
	)
	
	fn recalculateSegs scale = 
	(
		local transformedHeight = this.height*scale.z		
		local transformedRadius = (scale.x + scale.y)*0.5*radius
		
		local sectionHeightRelative= sectionHeight*transformedRadius
		numSegs = this.round (transformedHeight/sectionHeightRelative)
		
		-- limit the maximum numsegs to prevent crash
		if numSegs > 1000 then numSegs = 1000

		if numSegs < 0 then numSegs = numSegs*(-1)
		if numSegs < 1 then numSegs = 1
	)
	
	fn round floatVal =
	(
		local flooredVal = floor(floatVal)
		if floatVal - flooredVal > 0.5 then
		(
			return flooredVal + 1
		)
		else
		(
			return flooredVal
		)
	)
	
)

fn reinforceItChangeCallbackFn event nodes = 
(
	for i=1 to nodes.count do
	(
		node = (GetAnimByHandle nodes[i])		
		if (classof node) == RIBar then
		(
			if true then
			(
				node.recalculateSegs(node.scale)
			)
			
			
			if riVisualUVPickerDialogOpen then
			(
				riVisualUVPickerRollout.updateTextureBitmap()
			)
		)
	)
)

fn riVisualUVPickerMtlChangeCallbackFn event nodes = 
(
	if riVisualUVPickerDialogOpen then
	(
		riVisualUVPickerRollout.updateTextureBitmap()
	)
)



reinforceItChangeCallback = NodeEventCallback controllerOtherEvent:reinforceItChangeCallbackFn subobjectSelectionChanged:reinforceItChangeCallbackFn materialStructured:riVisualUVPickerMtlChangeCallbackFn