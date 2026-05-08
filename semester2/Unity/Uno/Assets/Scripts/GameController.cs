using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.UI;

public class GameController : MonoBehaviour
{
    public enum CardType
    {
        Zero,
        One,
        Two,
        Three,
        Four,
        Five,
        Six,
        Seven,
        Eight,
        Nine,
        Block,
        Turn,
        PlusTwo,
        ColorPicker,
        PlusFour,
        Blank,
        Cover
    }
    public enum CardColor
    {
        Yellow,
        Red,
        Green,
        Blue,
        None
    }

    public class Card
    {
        public CardType cardType;
        public CardColor cardColor;
        public Card(CardType ct, CardColor cc)
        {
            cardType = ct;
            cardColor = cc;
        }
    }

    [Header("Card")]
    [SerializeField] List<Sprite> cardSprites;
    [SerializeField] List<Color> cardColors;
    [SerializeField] GameObject cardPrefab;
    [Header("Decks")]
    [SerializeField] Transform playerDeck;
    [SerializeField] Transform enemyDeck;
    List<Card> deck;
    List<Card> playerCards = new List<Card>();
    List<Card> enemyCards = new List<Card>();

    private Image image;

    void Start()
    {
        DeckGeneration();
        Shuffle();
        StartingHand();
    }

    void DeckGeneration()
    {
        deck = new List<Card>();

        for(int i = 0; i < 8; i++)
        {
            for(int j = 0; j < 15; j++)
            {
                CardType type = (CardType)j;

                if(type == CardType.Zero && i > 3)
                {
                    continue;
                }

                CardColor color = (type == CardType.ColorPicker || type == CardType.PlusFour) ? CardColor.None : (CardColor)(i%4);
                Card card  = new Card(type, color);
                deck.Add(card);
            }
        }
    }

    void Shuffle()
    {
        deck = deck.OrderBy(_ => Random.Range(0f,1f)).ToList();
    }

    void StartingHand()
    {
        for(int i = 0; i < 7; i++)
        {
            playerCards.Add(deck[0]);

            image = Instantiate(cardPrefab, playerDeck).transform.GetChild(0).GetComponent<Image>();
            image.color = cardColors[(int)deck[0].cardColor];
            image.sprite = cardSprites[(int)deck[0].cardType];

            deck.RemoveAt(0);

            enemyCards.Add(deck[0]);

            image = Instantiate(cardPrefab, enemyDeck).transform.GetChild(0).GetComponent<Image>();
            image.color = cardColors[(int)CardColor.None];
            image.sprite = cardSprites[(int)CardType.Cover];

            deck.RemoveAt(0); 
        }
    }
}
