using UnityEngine;

public class ScreenEffect : MonoBehaviour
{
    [Range(0.1f, 23f)]
    [SerializeField] float value;

    public bool playGrowAnimation = true;
    public bool playShrinkAnimation = false;
    private bool grow, shrink;

    [SerializeField] private float duration = 1f;
    private float startTime;

    [SerializeField] private GameObject effectImage, blankImage;

    private void OnValidate()
    {
        ChangeScale(value);
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
        grow = true;
        startTime = Time.time;

        blankImage.SetActive(false);
        effectImage.SetActive(true);
    }

    public void StartShrinkAnimation()
    {
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
            shrink = false;
            blankImage.SetActive(true);
            effectImage.SetActive(false);
        }
    }
}