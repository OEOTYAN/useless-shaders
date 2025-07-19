void red_stone_level(inout bool needDiscard, inout bool isRedstoneDust, inout vec4 diffuse, vec3 cp, vec3 color)
{
    if (color.r > color.g + color.b)
    {
        if (color.r > 0.999 && color.g > 50.0 / 255.0 - 0.005 && color.g < 50.0 / 255.0 + 0.005 &&
            color.b < 0.005)
        {
            isRedstoneDust = true;
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (mod(floor(15.0 / exp2(floor((4.0 / 0.6) * (cp.x - 0.1)))) * 1.0, 2.0) >= 0.5 && cp.z <= 0.15 &&
                 cp.z >= 0.1) ||
                (cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
                (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
                (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
                (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.55 && cp.z >= 0.45) ||
                (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.55 && cp.z >= 0.25) ||
                (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 && cp.z >= 0.45) ||
                (cp.x <= 0.3 && cp.x >= 0.1 && cp.z <= 0.75 && cp.z >= 0.65) ||
                (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.35 && cp.z >= 0.25))
            {
                diffuse = vec4(1.0, 1.0, 1.0, 1.0);
                needDiscard = false;
            }
        }

        if (color.r > 244.0 / 255.0 - 0.005 && color.r < 244.0 / 255.0 + 0.005 &&
            color.g > 27.0 / 255.0 - 0.005 && color.g < 27.0 / 255.0 + 0.005 && color.b < 0.005)
        {
            isRedstoneDust = true;
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (mod(floor(14.0 / exp2(floor((4.0 / 0.6) * (cp.x - 0.1)))) * 1.0, 2.0) >= 0.5 && cp.z <= 0.15 &&
                 cp.z >= 0.1) ||
                (cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
                (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
                (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
                (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 && cp.z >= 0.25) ||
                (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 && cp.z >= 0.45) ||
                (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.55 && cp.z >= 0.45))
            {
                diffuse = vec4(1.0, 1.0, 1.0, 1.0);
                needDiscard = false;
            }
        }

        if (color.r > 234.0 / 255.0 - 0.005 && color.r < 234.0 / 255.0 + 0.005 &&
            color.g > 6.0 / 255.0 - 0.005 && color.g < 6.0 / 255.0 + 0.005 && color.b < 0.005)
        {
            isRedstoneDust = true;
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (mod(floor(13.0 / exp2(floor((4.0 / 0.6) * (cp.x - 0.1)))) * 1.0, 2.0) >= 0.5 && cp.z <= 0.15 &&
                 cp.z >= 0.1) ||
                (cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
                (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
                (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
                (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 && cp.z >= 0.25) ||
                (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.55 && cp.z >= 0.45) ||
                (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.35 && cp.z >= 0.25) ||
                (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.75 && cp.z >= 0.65))
            {
                diffuse = vec4(1.0, 1.0, 1.0, 1.0);
                needDiscard = false;
            }
        }

        if (color.r > 224.0 / 255.0 - 0.005 && color.r < 224.0 / 255.0 + 0.005 &&
            color.g + color.b < 0.005)
        {
            isRedstoneDust = true;
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (mod(floor(12.0 / exp2(floor((4.0 / 0.6) * (cp.x - 0.1)))) * 1.0, 2.0) >= 0.5 && cp.z <= 0.15 &&
                 cp.z >= 0.1) ||
                (cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
                (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
                (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
                (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.55 && cp.z >= 0.45) ||
                (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 && cp.z >= 0.45) ||
                (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.55 && cp.z >= 0.25) ||
                (cp.x <= 0.3 && cp.x >= 0.1 && cp.z <= 0.35 && cp.z >= 0.25) ||
                (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.75 && cp.z >= 0.65))
            {
                diffuse = vec4(1.0, 1.0, 1.0, 1.0);
                needDiscard = false;
            }
        }

        if (color.r > 214.0 / 255.0 - 0.005 && color.r < 214.0 / 255.0 + 0.005 &&
            color.g + color.b < 0.005)
        {
            isRedstoneDust = true;
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (mod(floor(11.0 / exp2(floor((4.0 / 0.6) * (cp.x - 0.1)))) * 1.0, 2.0) >= 0.5 && cp.z <= 0.15 &&
                 cp.z >= 0.1) ||
                (cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
                (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
                (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
                (cp.x <= 0.4 && cp.x >= 0.1 && cp.z <= 0.35 && cp.z >= 0.25) ||
                (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.75 && cp.z >= 0.35) ||
                (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 && cp.z >= 0.65))
            {
                diffuse = vec4(1.0, 1.0, 1.0, 1.0);
                needDiscard = false;
            }
        }

        if (color.r > 204.0 / 255.0 - 0.005 && color.r < 204.0 / 255.0 + 0.005 &&
            color.g + color.b < 0.005)
        {
            isRedstoneDust = true;
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (mod(floor(10.0 / exp2(floor((4.0 / 0.6) * (cp.x - 0.1)))) * 1.0, 2.0) >= 0.5 && cp.z <= 0.15 &&
                 cp.z >= 0.1) ||
                (cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
                (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
                (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
                (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 && cp.z >= 0.25) ||
                (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 && cp.z >= 0.25) ||
                (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.75 && cp.z >= 0.65) ||
                (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.35 && cp.z >= 0.25))
            {
                diffuse = vec4(1.0, 1.0, 1.0, 1.0);
                needDiscard = false;
            }
        }
        if (color.r > 193.0 / 255.0 - 0.005 && color.r < 193.0 / 255.0 + 0.005 &&
            color.g + color.b < 0.005)
        {
            isRedstoneDust = true;
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (mod(floor(9.0 / exp2(floor((4.0 / 0.6) * (cp.x - 0.1)))) * 1.0, 2.0) >= 0.5 && cp.z <= 0.15 &&
                 cp.z >= 0.1) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 && cp.z >= 0.45) ||
                (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.35) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 && cp.z >= 0.45) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65))
            {
                diffuse = vec4(1.0, 1.0, 1.0, 1.0);
                needDiscard = false;
            }
        }

        if (color.r > 183.0 / 255.0 - 0.005 && color.r < 183.0 / 255.0 + 0.005 &&
            color.g + color.b < 0.005)
        {
            isRedstoneDust = true;
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (mod(floor(8.0 / exp2(floor((4.0 / 0.6) * (cp.x - 0.1)))) * 1.0, 2.0) >= 0.5 && cp.z <= 0.15 &&
                 cp.z >= 0.1) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 && cp.z >= 0.45) ||
                (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.25) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 && cp.z >= 0.25) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25))
            {
                diffuse = vec4(1.0, 1.0, 1.0, 1.0);
                needDiscard = false;
            }
        }

        if (color.r > 173.0 / 255.0 - 0.005 && color.r < 173.0 / 255.0 + 0.005 &&
            color.g + color.b < 0.005)
        {
            isRedstoneDust = true;
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (mod(floor(7.0 / exp2(floor((4.0 / 0.6) * (cp.x - 0.1)))) * 1.0, 2.0) >= 0.5 && cp.z <= 0.15 &&
                 cp.z >= 0.1) ||
                (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.25) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.65 && cp.z >= 0.55))
            {
                diffuse = vec4(1.0, 1.0, 1.0, 1.0);
                needDiscard = false;
            }
        }

        if (color.r > 163.0 / 255.0 - 0.005 && color.r < 163.0 / 255.0 + 0.005 &&
            color.g + color.b < 0.005)
        {
            isRedstoneDust = true;
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (mod(floor(6.0 / exp2(floor((4.0 / 0.6) * (cp.x - 0.1)))) * 1.0, 2.0) >= 0.5 && cp.z <= 0.15 &&
                 cp.z >= 0.1) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 && cp.z >= 0.45) ||
                (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.55 && cp.z >= 0.25) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 && cp.z >= 0.35) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25))
            {
                diffuse = vec4(1.0, 1.0, 1.0, 1.0);
                needDiscard = false;
            }
        }

        if (color.r > 153.0 / 255.0 - 0.005 && color.r < 153.0 / 255.0 + 0.005 &&
            color.g + color.b < 0.005)
        {
            isRedstoneDust = true;
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (mod(floor(5.0 / exp2(floor((4.0 / 0.6) * (cp.x - 0.1)))) * 1.0, 2.0) >= 0.5 && cp.z <= 0.15 &&
                 cp.z >= 0.1) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 && cp.z >= 0.45) ||
                (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.55 && cp.z >= 0.25) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 && cp.z >= 0.45) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25))
            {
                diffuse = vec4(1.0, 1.0, 1.0, 1.0);
                needDiscard = false;
            }
        }

        if (color.r > 142.0 / 255.0 - 0.005 && color.r < 142.0 / 255.0 + 0.005 &&
            color.g + color.b < 0.005)
        {
            isRedstoneDust = true;
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (mod(floor(4.0 / exp2(floor((4.0 / 0.6) * (cp.x - 0.1)))) * 1.0, 2.0) >= 0.5 && cp.z <= 0.15 &&
                 cp.z >= 0.1) ||
                (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.25) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 && cp.z >= 0.45) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 && cp.z >= 0.45))
            {
                diffuse = vec4(1.0, 1.0, 1.0, 1.0);
                needDiscard = false;
            }
        }

        if (color.r > 132.0 / 255.0 - 0.005 && color.r < 132.0 / 255.0 + 0.005 &&
            color.g + color.b < 0.005)
        {
            isRedstoneDust = true;
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (mod(floor(3.0 / exp2(floor((4.0 / 0.6) * (cp.x - 0.1)))) * 1.0, 2.0) >= 0.5 && cp.z <= 0.15 &&
                 cp.z >= 0.1) ||
                (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.25) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 && cp.z >= 0.45) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65))
            {
                diffuse = vec4(1.0, 1.0, 1.0, 1.0);
                needDiscard = false;
            }
        }

        if (color.r > 122.0 / 255.0 - 0.005 && color.r < 122.0 / 255.0 + 0.005 &&
            color.g + color.b < 0.005)
        {
            isRedstoneDust = true;
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (mod(floor(2.0 / exp2(floor((4.0 / 0.6) * (cp.x - 0.1)))) * 1.0, 2.0) >= 0.5 && cp.z <= 0.15 &&
                 cp.z >= 0.1) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 && cp.z >= 0.45) ||
                (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.45) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.55 && cp.z >= 0.25) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65))
            {
                diffuse = vec4(1.0, 1.0, 1.0, 1.0);
                needDiscard = false;
            }
        }

        if (color.r > 112.0 / 255.0 - 0.005 && color.r < 112.0 / 255.0 + 0.005 &&
            color.g + color.b < 0.005)
        {
            isRedstoneDust = true;
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (mod(floor(1.0 / exp2(floor((4.0 / 0.6) * (cp.x - 0.1)))) * 1.0, 2.0) >= 0.5 && cp.z <= 0.15 &&
                 cp.z >= 0.1) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 && cp.z >= 0.35) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65))
            {
                diffuse = vec4(1.0, 1.0, 1.0, 1.0);
                needDiscard = false;
            }
        }

        if (color.r > 76.0 / 255.0 - 0.005 && color.r < 76.0 / 255.0 + 0.005 && color.g + color.b < 0.005)
        {
            isRedstoneDust = true;
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.25) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 && cp.z >= 0.25) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25))
            {
                diffuse = vec4(1.0, 1.0, 1.0, 1.0);
                needDiscard = false;
            }
        }
    }
}
void light_overlay(inout bool needDiscard, inout int isLightOverlay, vec3 cp, vec2 light_uv)
{

    cp.x = cp.x - 0.13;
    // x
    if (light_uv.x == 0.0)
    {
        if ((cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.25) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 && cp.z >= 0.25) ||
            (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25))
        {
            isLightOverlay = 2;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.x > 0.0 && light_uv.x <= 0.125)
    {
        if ((cp.x <= 0.4 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 && cp.z >= 0.35) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.x > 0.125 && light_uv.x <= 0.1875)
    {
        if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 && cp.z >= 0.45) ||
            (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.45) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.55 && cp.z >= 0.25) ||
            (cp.x <= 0.3 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.x > 0.1875 && light_uv.x <= 0.25)
    {
        if ((cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.25) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 && cp.z >= 0.45) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.x > 0.25 && light_uv.x <= 0.3125)
    {
        if ((cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.25) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 && cp.z >= 0.45) ||
            (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 && cp.z >= 0.45))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.x > 0.3125 && light_uv.x <= 0.375)
    {
        if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 && cp.z >= 0.45) ||
            (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.55 && cp.z >= 0.25) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 && cp.z >= 0.45) ||
            (cp.x <= 0.3 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.x > 0.375 && light_uv.x <= 0.4375)
    {
        if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 && cp.z >= 0.45) ||
            (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.55 && cp.z >= 0.25) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 && cp.z >= 0.35) ||
            (cp.x <= 0.3 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.x > 0.4375 && light_uv.x <= 0.5)
    {
        if ((cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.25) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.65 && cp.z >= 0.55))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.x > 0.5 && light_uv.x <= 0.5625)
    {
        if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 && cp.z >= 0.45) ||
            (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.25) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 && cp.z >= 0.25) ||
            (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.x > 0.5625 && light_uv.x <= 0.625)
    {
        if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 && cp.z >= 0.45) ||
            (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.35) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 && cp.z >= 0.45) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.x > 0.625 && light_uv.x <= 0.6875)
    {
        if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
            (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 && cp.z >= 0.25) ||
            (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 && cp.z >= 0.25) ||
            (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.35 && cp.z >= 0.25))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.x > 0.6875 && light_uv.x <= 0.75)
    {
        if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
            (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.4 && cp.x >= 0.1 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.75 && cp.z >= 0.35) ||
            (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 && cp.z >= 0.65))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.x > 0.75 && light_uv.x <= 0.8125)
    {
        if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
            (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.55 && cp.z >= 0.45) ||
            (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 && cp.z >= 0.45) ||
            (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.55 && cp.z >= 0.25) ||
            (cp.x <= 0.3 && cp.x >= 0.1 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.75 && cp.z >= 0.65))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.x > 0.8125 && light_uv.x <= 0.875)
    {
        if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
            (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 && cp.z >= 0.25) ||
            (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.55 && cp.z >= 0.45) ||
            (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.75 && cp.z >= 0.65))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.x > 0.875 && light_uv.x <= 0.9375)
    {
        if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
            (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 && cp.z >= 0.25) ||
            (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 && cp.z >= 0.45) ||
            (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.55 && cp.z >= 0.45))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.x > 0.9375)
    {
        if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
            (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.55 && cp.z >= 0.45) ||
            (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.55 && cp.z >= 0.25) ||
            (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 && cp.z >= 0.45) ||
            (cp.x <= 0.3 && cp.x >= 0.1 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.35 && cp.z >= 0.25))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }

    cp.x = cp.x * 2.0 + 0.55;
    cp.z = cp.z * 2.0 - 0.25;
    // y
    if (light_uv.y == 0.0)
    {
        if ((cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.25) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 && cp.z >= 0.25) ||
            (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25))
        {
            isLightOverlay = 2;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.y > 0.0 && light_uv.y <= 0.125)
    {
        if ((cp.x <= 0.4 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 && cp.z >= 0.35) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.y > 0.125 && light_uv.y <= 0.1875)
    {
        if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 && cp.z >= 0.45) ||
            (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.45) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.55 && cp.z >= 0.25) ||
            (cp.x <= 0.3 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.y > 0.1875 && light_uv.y <= 0.25)
    {
        if ((cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.25) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 && cp.z >= 0.45) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.y > 0.25 && light_uv.y <= 0.3125)
    {
        if ((cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.25) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 && cp.z >= 0.45) ||
            (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 && cp.z >= 0.45))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.y > 0.3125 && light_uv.y <= 0.375)
    {
        if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 && cp.z >= 0.45) ||
            (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.55 && cp.z >= 0.25) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 && cp.z >= 0.45) ||
            (cp.x <= 0.3 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.y > 0.375 && light_uv.y <= 0.4375)
    {
        if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 && cp.z >= 0.45) ||
            (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.55 && cp.z >= 0.25) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 && cp.z >= 0.35) ||
            (cp.x <= 0.3 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.y > 0.4375 && light_uv.y <= 0.5)
    {
        if ((cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.25) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.65 && cp.z >= 0.55))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.y > 0.5 && light_uv.y <= 0.5625)
    {
        if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 && cp.z >= 0.45) ||
            (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.25) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 && cp.z >= 0.25) ||
            (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.y > 0.5625 && light_uv.y <= 0.625)
    {
        if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 && cp.z >= 0.45) ||
            (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 && cp.z >= 0.35) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 && cp.z >= 0.45) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 && cp.z >= 0.65))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.y > 0.625 && light_uv.y <= 0.6875)
    {
        if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
            (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 && cp.z >= 0.25) ||
            (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 && cp.z >= 0.25) ||
            (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.35 && cp.z >= 0.25))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.y > 0.6875 && light_uv.y <= 0.75)
    {
        if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
            (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.4 && cp.x >= 0.1 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.75 && cp.z >= 0.35) ||
            (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 && cp.z >= 0.65))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.y > 0.75 && light_uv.y <= 0.8125)
    {
        if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
            (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.55 && cp.z >= 0.45) ||
            (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 && cp.z >= 0.45) ||
            (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.55 && cp.z >= 0.25) ||
            (cp.x <= 0.3 && cp.x >= 0.1 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.75 && cp.z >= 0.65))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.y > 0.8125 && light_uv.y <= 0.875)
    {
        if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
            (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 && cp.z >= 0.25) ||
            (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.55 && cp.z >= 0.45) ||
            (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.75 && cp.z >= 0.65))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.y > 0.875 && light_uv.y <= 0.9375)
    {
        if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
            (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 && cp.z >= 0.25) ||
            (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 && cp.z >= 0.45) ||
            (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.55 && cp.z >= 0.45))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
    else if (light_uv.y > 0.9375)
    {
        if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
            (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
            (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.55 && cp.z >= 0.45) ||
            (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.55 && cp.z >= 0.25) ||
            (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 && cp.z >= 0.45) ||
            (cp.x <= 0.3 && cp.x >= 0.1 && cp.z <= 0.75 && cp.z >= 0.65) ||
            (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.35 && cp.z >= 0.25))
        {
            isLightOverlay = 1;
#ifdef ALPHA_TEST_PASS
            needDiscard = false;
#endif
        }
    }
}
void chunk_border(inout vec4 diffuse, vec3 chunkPos)
{
#define NO_MSAA

#ifdef NO_MSAA

    vec3 cp = fract(chunkPos);

    if (((chunkPos.x < 0.0625 || chunkPos.x > 15.9375) && (chunkPos.y < 0.0625 || chunkPos.y > 15.9375)) ||
        ((chunkPos.x < 0.0625 || chunkPos.x > 15.9375) && (chunkPos.z < 0.0625 || chunkPos.z > 15.9375)) ||
        ((chunkPos.y < 0.0625 || chunkPos.y > 15.9375) && (chunkPos.z < 0.0625 || chunkPos.z > 15.9375)))
    {
        diffuse.rgb = mix(diffuse.rgb, max(chunkPos.z, chunkPos.x) < 0.0625 ? vec3(1.0, 0.2, 0.2) : vec3(0.0, 0.0, 1.0), 0.2);
    }
    else if (((chunkPos.x < 0.03125 || chunkPos.x > 15.96875) || (chunkPos.z < 0.03125 || chunkPos.z > 15.96875)) &&
             (((cp.x < 0.03125 || cp.x > 0.96875) && (cp.y < 0.03125 || cp.y > 0.96875)) ||
              ((cp.x < 0.03125 || cp.x > 0.96875) && (cp.z < 0.03125 || cp.z > 0.96875)) ||
              ((cp.y < 0.03125 || cp.y > 0.96875) && (cp.z < 0.03125 || cp.z > 0.96875))))
    {
        diffuse.rgb = (diffuse.rgb / 0.4) * (vec3(1.0, 1.0, 1.0) - diffuse.rgb);
    }

#else

    vec3 cp = fract(chunkPos);
    vec3 ch = chunkPos;
    vec3 chw = fwidth(ch);
    vec3 chdx = dFdx(ch);
    vec3 chdy = dFdy(ch);
    vec3 linea = 0.0626;       // 0.0625
    vec3 lineb = 0.0627 / 2.0; // 0.0625 / 2.0
    int ckk = 1;
    if (((chunkPos.x < linea.x + chw.x || chunkPos.x > 16.0 - linea.x - chw.x) ||
         (chunkPos.z < linea.z + chw.z || chunkPos.z > 16.0 - linea.z - chw.z)) &&
        (((cp.x < lineb.x + chw.x || cp.x > 1.0 - lineb.x - chw.x) &&
          (cp.y < lineb.y + chw.y || cp.y > 1.0 - lineb.y - chw.y)) ||
         ((cp.x < lineb.x + chw.x || cp.x > 1.0 - lineb.x - chw.x) &&
          (cp.z < lineb.z + chw.z || cp.z > 1.0 - lineb.z - chw.z)) ||
         ((cp.y < lineb.y + chw.y || cp.y > 1.0 - lineb.y - chw.y) &&
          (cp.z < lineb.z + chw.z || cp.z > 1.0 - lineb.z - chw.z))))
        ckk = 5;
    int l1 = 0;
    int l2 = 0;
    int lrrr = 0;
    for (int ci = 0;
         ci < ckk;
         ci++)
        for (int cj = 0;
             cj < ckk;
             cj++)
        {
            vec3 lchunkPos = fract((chunkPos + chdx * ci / float(ckk) + chdy * cj / float(ckk)) / 16.0) * 16.0;
            vec3 lcp = fract(cp + chdx * ci / float(ckk) + chdy * cj / float(ckk));

            if (((lchunkPos.x < linea.x || lchunkPos.x > 16.0 - linea.x) &&
                 (lchunkPos.y < linea.y || lchunkPos.y > 16.0 - linea.y)) ||
                ((lchunkPos.x < linea.x || lchunkPos.x > 16.0 - linea.x) &&
                 (lchunkPos.z < linea.z || lchunkPos.z > 16.0 - linea.z)) ||
                ((lchunkPos.y < linea.y || lchunkPos.y > 16.0 - linea.y) &&
                 (lchunkPos.z < linea.z || lchunkPos.z > 16.0 - linea.z)))
                l1 += 1;
            else if (((lchunkPos.x < lineb.x || lchunkPos.x > 16.0 - lineb.x) ||
                      (lchunkPos.z < lineb.z || lchunkPos.z > 16.0 - lineb.z)) &&
                     (((lcp.x < lineb.x || lcp.x > 1.0 - lineb.x) && (lcp.y < lineb.y || lcp.y > 1.0 - lineb.y)) ||
                      ((lcp.x < lineb.x || lcp.x > 1.0 - lineb.x) && (lcp.z < lineb.z || lcp.z > 1.0 - lineb.z)) ||
                      ((lcp.y < lineb.y || lcp.y > 1.0 - lineb.y) && (lcp.z < lineb.z || lcp.z > 1.0 - lineb.z))))
                l2 += 1;
            else
                lrrr += 1;
        }

    float weightq = ckk;
    weightq = 1.0 / weightq / weightq;
    diffuse.rgb = diffuse.rgb * lrrr * weightq + (mix(diffuse.rgb, max(chunkPos.z, chunkPos.x) < 0.0625 ? vec3(1.0, 0.2, 0.2) : vec3(0.0, 0.0, 1.0), 0.2) * weightq * l1 + (diffuse.rgb / 0.4) * (vec3(1.0, 1.0, 1.0) - diffuse.rgb) * weightq * l2);
#endif
}
