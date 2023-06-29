---==Helpers matemáticos==--

PI = math.pi

--Retorna o valor em radianos equivalente ao parâmetro em graus
function getRad(angle)
    return angle * PI/180
end

function degreeToRad(degree)
    return degree/180 * PI
end

--Retorna o valor de radiano equivalente dentro do intervalo [0, 2*PI]
function getPositiveRad(rad)

    local radAbs = math.abs(rad)

    if radAbs > 2 * PI then
        rad = (radAbs - 2 * PI) * rad/radAbs
    end

    if rad < 0 then
        return 2 * PI + rad
    end
        return rad

end

--Retorna a distância entre dois pontos
function getPointsDistance(x1, y1, x2, y2)
    return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

--Retorna o parâmetro ou o valor máximo permitido para ele
function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end