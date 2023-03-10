using UnityEngine;
using UnityEngine.Events;

[System.Serializable] public class ScreenEffectEvent : UnityEvent { }
public class ScreenEffect : MonoBehaviour
{
    public ScreenEffectEvent OnGrown, OnShrunk;

    [Range(0.1f, 23f)]
    [SerializeField] float value = 23f;

    public bool playGrowAnimation = true;
    public bool playShrinkAnimation = false;
    private bool grow, shrink;

    [SerializeField] private float duration = 1f;
    private float startTime;

    [SerializeField] private GameObject blankImage;
    private GameObject effectImage;

    private void OnValidate()
    {
        ChangeScale(value);
    }

    private void Awake()
    {
        effectImage = transform.GetChild(0).gameObject;
    }

    private void Start()
    {
        effectImage.SetActive(false);
        blankImage.SetActive(false);
    }

    private void Update()
    {
        if (playGrowAnimation && !shrink)
        {
            playGrowAnimation = false;

            StartGrowAnimation();
        }
        else
        if (playShrinkAnimation && !grow)
        {
            playShrinkAnimation = false;

            StartShrinkAnimation();
        }

        if (grow)
            GrowAnimation();

        if (shrink)
            ShrinkAnimation();
    }

    private void ChangeScale(float scale)
    {
        transform.localScale = scale * Vector3.one;
    }

    public void StartGrowAnimation()
    {
        if (shrink)
        {
            playGrowAnimation = true;
            return;
        }

        grow = true;
        startTime = Time.time;

        blankImage.SetActive(false);
        effectImage.SetActive(true);
    }

    public void StartShrinkAnimation()
    {
        if (grow)
        {
            playShrinkAnimation = true;
            return;
        }

        shrink = true;
        startTime = Time.time;

        blankImage.SetActive(false);
        effectImage.SetActive(true);
    }

    private void GrowAnimation()
    {
        var t = (Time.time - startTime) / duration;
        ChangeScale(Mathf.Lerp(0.1f, 23f, t));

        if (t >= 1f) // animation ended
        {
            OnGrown?.Invoke();

            grow = false;
            blankImage.SetActive(false);
            effectImage.SetActive(false);
        }
    }

    private void ShrinkAnimation()
    {
        var t = (Time.time - startTime) / duration;
        ChangeScale(Mathf.Lerp(23f, 0.1f, t));

        if (t >= 1f) // animation ended
        {
            OnShrunk?.Invoke();

            shrink = false;
            blankImage.SetActive(true);
            effectImage.SetActive(false);
        }
    }
}