using Celeste.Mod.Entities;
using Microsoft.Xna.Framework;
using Monocle;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Celeste.Mod.CommunalHelper.Entities {

    [CustomEntity("CommunalHelper/Melvin")]
    class Melvin : Solid {

        private bool triggered = true;

        public Melvin(EntityData data, Vector2 offset)
            : this(data.Position + offset, data.Width, data.Height) { }

        public Melvin(Vector2 position, int width, int height)
            : base(position, width, height, safe: false) {

            int w = (int) (base.Width / 8f);
            int h = (int) (base.Height / 8f);

            MTexture block = GFX.Game["objects/CommunalHelper/melvin/block"];
            for (int i = 0; i < w; i++) {
                for (int j = 0; j < h; j++) {
                    int tx = (i == 0) ? 0 : ((i == w - 1) ? 3 : Calc.Random.Choose(1, 2));
                    int ty = (j == 0) ? 0 : ((j == h - 1) ? 3 : Calc.Random.Choose(1, 2));

                    Image image = new Image(block.GetSubtexture(tx * 8, ty * 8, 8, 8));
                    image.Position = new Vector2(i * 8, j * 8);

                    Add(image);
                }
            }
            

            Add(new LightOcclude(0.2f));
        }

        public override void Render() {
            Vector2 position = Position;
            Position += Shake;

            base.Render();

            Position = position;
        }

    }
}
