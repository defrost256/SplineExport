macroScript UE4splineWriter
category:"UE4"
toolTip:"UE4 Spline Export"
buttonText:"UE4 Spline Export"
Icon:#("Splines", 1)

(
    fn SplineCOPY =
    (
        vertPosArray = #()
        vertInArray = #()
        vertOutArray = #()

        --(ArriveTangent=(X=24.055420,Y=-42.968018,Z=0.000000),
        --LeaveTangent=(X=24.055420,Y=-42.968018,Z=0.000000),
        --InterpMode=CIM_CurveUser),
        --(InVal=1.000000,OutVal=(X=40.460693,Y=25.782288,Z=0.000000)

        splinePointTempl = "(InVal=%,OutVal=(X=%,Y=%,Z=%),"
        splineTanTempl = "ArriveTangent=(X=%,Y=%,Z=%),LeaveTangent=(X=%,Y=%,Z=%),InterpMode=CIM_CurveUser)"
        rotationNullStr = "(InVal=%,ArriveTangent=(X=0.000000,Y=0.000000,Z=0.000000,W=0.500000),LeaveTangent=(X=0.000000,Y=0.000000,Z=0.000000,W=0.500000),InterpMode=CIM_CurveAuto)"
        scaleOneStr = "(InVal=%,OutVal=(X=1.000000,Y=1.000000,Z=1.000000),InterpMode=CIM_CurveAuto)"
        reparamTableStr = "(InVal=%,OutVal=%)"

        theSpline = convertToSplineShape $
        theSpline = $

        numPoints = numKnots theSpline 1

        outputStr = stringstream ""

        for v = 1 to numPoints do
        (
            vertPos = in coordsys world getKnotPoint theSpline 1 v
            vertPos = vertPos * [1,-1,1]

            vertIn = in coordsys world getInVec theSpline 1 v
            vertIn = vertIn * [1,-1,1]
            vertIn = (vertPos - vertIn) * 3.0

            vertOut = in coordsys world getOutVec theSpline 1 v
            vertOut = vertOut * [1,-1,1]
            vertOut = (vertOut - vertPos) * 3.0

            if v != 1 do
                vertPos = vertPos - vertPosArray[1]

            append vertPosArray vertPos
            append vertInArray vertIn
            append vertOutArray vertOut
        )
        --Basic Object Definitions
        format "Begin Map\n\tBegin Level\n\t\tBegin Actor Class=Actor Name=Spline\n\t\t\tBegin Object Class=SplineComponent Name=\"Spline\"\n\t\t\tEnd Object\n\t\t\tBegin Object Name=\"Spline\"\n\t\t\t\tSplineCurves=(Position=(Points=(" to:outputStr
        --Point strings
        for i = 1 to numPoints do
        (
      			if i != 1 then
      			(
                format splinePointTempl (i - 1) vertPosArray[i][1] vertPosArray[i][2] vertPosArray[i][3] to:outputStr
  			    )
            else
            (
                format "(" to:outputStr
            )
                format splineTanTempl vertInArray[i][1] vertInArray[i][2] vertInArray[i][3] vertOutArray[i][1] vertOutArray[i][2] vertOutArray[i][3] to:outputStr
                if i < numPoints do
                    format "," to:outputStr
        )

        format ")),Rotation=(Points=((InterpMode=CIM_CurveAuto)," to:outputStr
        --Rotation Strings
        for i = 2 to numPoints do
        (
            format rotationNullStr (i - 1) to:outputStr
            if i < numPoints do
                format "," to:outputStr
        )

        format ")),Scale=(Points=((OutVal=(X=1.000000,Y=1.000000,Z=1.000000),InterpMode=CIM_CurveAuto)," to:outputStr

        for i = 2 to numPoints do
        (
            format scaleOneStr (i - 1) to:outputStr
            if i < numPoints do
                format "," to:outputStr
        )

        format ")),ReparamTable=(Points=(()," to:outputStr

		segLengths = getSegLengths theSpline 1 cum:true
		print segLengths
		print "-----"
        for i = 0.1 to numPoints - 0.99 by 0.1 do
        (
      			currentSegAndLength = findLengthSegAndParam theSpline 1 (i / numPoints)
      			print currentSegAndLength
            format reparamTableStr (segLengths[currentSegAndLength[1] + (numPoints - 1)] * currentSegAndLength[2]) i to:outputStr
            if i < (numPoints - 1.05) do
                format "," to:outputStr
        )

        format ")))\n\t\t\t\tbSplineHasBeenEdited=True\n\t\t\t\tbAllowDiscontinuousSpline=True\n\t\t\t\tRelativeLocation(X=%,Y=%,Z=%)" vertPosArray[1][1] vertPosArray[1][2] vertPosArray[1][3] to:outputStr
        format "\n\t\t\t\tCreationMethod=Instance\n\t\t\tEnd Object\n\t\t\tRootComponent=SplineComponent'Spline'\n\t\t\tnstanceComponents(0)=SplineComponent'Spline'\n\t\tEnd Actor\n\tEnd Level\nBegin Surface\nEnd Surface\nEnd Map" to:outputStr

        setClipBoardText outputStr
    )

    rollout UE4SplineExportRollout "UE4 Spline Exporter"
    (
        label lbl0 ""
        label lbl1 "Select Spline Shape"
        label lbl2 ""
        button btn_writeSpline "Copy Spline to Clipboard" tooltip: "Copies the selected spline to the clipboard"

        on btn_writeSpline pressed do
        (
            SplineCOPY()
        )
    )

    if UE4splineExportFloater != undefined then closeRolloutFloater UE4splineExportFloater

    UE4splineExportFloater = newRolloutFloater "UE4 Spline Exporter" 260 120
    addRollout UE4SplineExportRollout UE4splineExportFloater
)
