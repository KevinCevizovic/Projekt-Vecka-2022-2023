using UnityEngine;

public class ScreenEffect : MonoBehaviour
{
    [Range(0.1f, 23f)]
    [SerializeField] float value;

    public bool playGrowAnimation = true;
    public bool playShrinkAnimation = false;

    private bool grow, shrink;

    [SerializeField] private float duration = 1f;

    [SerializeField] private GameObject child, image;

    private float startTime;

    private void OnValidate()
    {
        ChangeScale(value);
    }

    private void Start()
    {
        child.SetActive(false);
        image.SetActive(false);
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

        image.SetActive(false);
        child.SetActive(true);
    }

    public void StartShrinkAnimation()
    {
        shrink = true;
        startTime = Time.time;

        image.SetActive(false);
        child.SetActive(true);
    }

    private void GrowAnimation()
    {
        var e = (Time.time - startTime) / duration;
        ChangeScale(Mathf.Lerp(0.1f, 23f, e));

        if (e >= 1f)
        {
            grow = false;
            image.SetActive(false);
            child.SetActive(false);
        }
    }

    public void ShrinkAnimation()
    {
        var e = (Time.time - startTime) / duration;
        ChangeScale(Mathf.Lerp(23f, 0.1f, e));

        if (e >= 1f)
        {
            shrink = false;
            image.SetActive(true);
            child.SetActive(false);
        }
    }
}