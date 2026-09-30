using System;
using System.Collections.Generic;
using System.Text;

namespace Hunt.Model
{
    public class GameEventArgs : EventArgs
    {
        public bool IsGameOver { get; set; }
        public Player? Winner { get; set; }
        public int RoundsPlayed { get; set; }
    }
}
