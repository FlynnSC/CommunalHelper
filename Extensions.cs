﻿using Celeste.Mod.CommunalHelper.Entities;
using Microsoft.Xna.Framework;
using MonoMod.Utils;

namespace Celeste.Mod.CommunalHelper {
    public static class Extensions {

        public static DynData<Player> GetData(this Player player) {
            return new DynData<Player>(player);
        }

        public static Color Mult(this Color color, Color other) {
            color.R = (byte) (color.R * other.R / 256f);
            color.G = (byte) (color.G * other.G / 256f);
            color.B = (byte) (color.B * other.B / 256f);
            color.A = (byte) (color.A * other.A / 256f);
            return color;
        }

        // Dream Tunnel Dash related extension methods located in DreamTunnelDash.cs

        #region WallBoosters

        public static bool AttachedWallBoosterCheck(this Player player) {
            foreach (AttachedWallBooster wallbooster in player.Scene.Tracker.GetEntities<AttachedWallBooster>()) {
                if (player.Facing == wallbooster.Facing && player.CollideCheck(wallbooster))
                    return true;
            }
            return false;
        }

        #endregion

    }
}