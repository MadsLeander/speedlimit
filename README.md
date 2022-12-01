# Speedlimit

Speedlimits is a standalone script that shows lore-friendly speed limits on customizable nui signs. The script’s usage of vehicle nodes allows the speed limits to be much more accurate than other scripts. For example, it allows for multiple speed limits on the same street as well as advisory/recommended speed signs. Furthermore, you can add custom signs or use any of the signs that already come with the script (See Configuration).

*By default, the speed limits are based on in-game signs, NPC speeds, and the road’s real-life counterparts. (you can of course change them to whatever you like)

This resource initially got inspiration from here: https://forum.cfx.re/t/free-on-screen-nui-speedlimit-signs/4810573.

Youtube Preview: https://www.youtube.com/watch?v=Bcip-LjSOJE  
FiveM Forums: https://forum.cfx.re/t/release-speedlimits/4960836

## Optimization
The script runs at 0.00ms when you’re not in a vehicle. It uses between 0.01ms to 0.03ms when it’s active.

## Configuration
The script can be configured to your liking.

## Custom Signs
There are 15 different signs included with the script. They are not guaranteed to work 100% as the script was originally made to only work with regular US signs. You can also add custom signs and fonts yourself.

## Custom Sign Position/Size
You can freely change the position and size in the CSS file. Here is an example of how you could put it inside the minimap:

```
/* These should replace their counterparts that already exist in the CSS file */
#container {
    display: none;
    position: absolute;
    left: 4vh;
    bottom: 4vh;
}

#background {
    background-repeat: no-repeat;
    background-size: cover;
    height: 3rem;
    width: 3rem;
}

.background-us-standard {
    background: url("images/us_standard.png");
}
.numerals-us-standard {
    color: rgb(35, 31, 32);
    font-size: 1.25rem;
    font-weight: bold;
    font-family: highwaygothic;
    padding-top: 1.55rem;
    transform:scale(1.1, 1);
    letter-spacing: 0.1rem;
    text-indent: 0.1rem;
}
```
